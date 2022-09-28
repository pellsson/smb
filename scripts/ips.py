# https://github.com/nleseul/ips_util

import itertools

class Patch:
    @staticmethod
    def load(filename):
        loaded_patch = Patch()

        with open(filename, 'rb') as file:

            header = file.read(5)
            if header != 'PATCH'.encode('ascii'):
                raise Exception('Not a valid IPS patch file!')
            while True:
                address_bytes = file.read(3)
                if address_bytes == 'EOF'.encode('ascii'):
                    break
                address = int.from_bytes(address_bytes, byteorder='big')

                length = int.from_bytes(file.read(2), byteorder='big')
                rle_count = 0
                if length == 0:
                    rle_count = int.from_bytes(file.read(2), byteorder='big')
                    length = 1
                data = file.read(length)

                if rle_count > 0:
                    loaded_patch.add_rle_record(address, data, rle_count)
                else:
                    loaded_patch.add_record(address, data)

            truncate_bytes = file.read(3)
            if len(truncate_bytes) == 3:
                loaded_patch.set_truncate_length(int.from_bytes(truncate_bytes, byteorder='big'))

        return loaded_patch

    @staticmethod
    def create(original_data, patched_data):
        # The heuristics for optimizing a patch were chosen with reference to
        # the source code of Flips: https://github.com/Alcaro/Flips

        patch = Patch()

        run_in_progress = False
        current_run_start = 0
        current_run_data = bytearray()

        runs = []

        if len(original_data) > len(patched_data):
            patch.set_truncate_length(len(patched_data))
            original_data = original_data[:len(patched_data)]
        elif len(original_data) < len(patched_data):
            original_data += bytes([0] * (len(patched_data) - len(original_data)))

            if original_data[-1] == 0 and patched_data[-1] == 0:
                patch.add_record(len(patched_data) - 1, bytes([0]))

        for index, (original, patched) in enumerate(zip(original_data, patched_data)):
            if not run_in_progress:
                if original != patched:
                    run_in_progress = True
                    current_run_start = index
                    current_run_data = bytearray([patched])
            else:
                if original == patched:
                    runs.append((current_run_start, current_run_data))
                    run_in_progress = False
                else:
                    current_run_data.append(patched)
        if run_in_progress:
            runs.append((current_run_start, current_run_data))

        for start, data in runs:
            if start == int.from_bytes(b'EOF', byteorder='big'):
                start -= 1
                data = bytes([patched_data[start - 1]]) + data

            grouped_byte_data = list([
                {'val': key, 'count': sum(1 for _ in group), 'is_last': False}
                for key,group in itertools.groupby(data)
            ])

            grouped_byte_data[-1]['is_last'] = True

            record_in_progress = bytearray()
            pos = start

            for group in grouped_byte_data:
                if len(record_in_progress) > 0:
                    # We don't want to interrupt a record in progress with a new header unless
                    # this group is longer than two complete headers.
                    if group['count'] > 13:
                        patch.add_record(pos, record_in_progress)
                        pos += len(record_in_progress)
                        record_in_progress = bytearray()

                        patch.add_rle_record(pos, bytes([group['val']]), group['count'])
                        pos += group['count']
                    else:
                        record_in_progress += bytes([group['val']] * group['count'])
                elif (group['count'] > 3 and group['is_last']) or group['count'] > 8:
                    # We benefit from making this an RLE record if the length is at least 8,
                    # or the length is at least 3 and we know it to be the last part of this diff.

                    # Make sure not to overflow the maximum length. Split it up if necessary.
                    remaining_length = group['count']
                    while remaining_length > 0xffff:
                        patch.add_rle_record(pos, bytes([group['val']]), 0xffff)
                        remaining_length -= 0xffff
                        pos += 0xffff

                    patch.add_rle_record(pos, bytes([group['val']]), remaining_length)
                    pos += remaining_length
                else:
                    # Just begin a new standard record.
                    record_in_progress += bytes([group['val']] * group['count'])

                if len(record_in_progress) > 0xffff:
                    patch.add_record(pos, record_in_progress[:0xffff])
                    record_in_progress = record_in_progress[0xffff:]
                    pos += 0xffff

            # Finalize any record still in progress.
            if len(record_in_progress) > 0:
                patch.add_record(pos, record_in_progress)

        return patch

    def __init__(self):
        self.records = []
        self.truncate_length = None

    def add_record(self, address, data):
        if address == int.from_bytes(b'EOF', byteorder='big'):
            raise RuntimeError('Start address {0:x} is invalid in the IPS format. Please shift your starting address back by one byte to avoid it.'.format(address))
        if address > 0xffffff:
            raise RuntimeError('Start address {0:x} is too large for the IPS format. Addresses must fit into 3 bytes.'.format(address))
        if len(data) > 0xffff:
            raise RuntimeError('Record with length {0} is too large for the IPS format. Records must be less than 65536 bytes.'.format(len(data)))

        record = {'address': address, 'data': data}
        self.records.append(record)

    def add_rle_record(self, address, data, count):
        if address == int.from_bytes(b'EOF', byteorder='big'):
            raise RuntimeError('Start address {0:x} is invalid in the IPS format. Please shift your starting address back by one byte to avoid it.'.format(address))
        if address > 0xffffff:
            raise RuntimeError('Start address {0:x} is too large for the IPS format. Addresses must fit into 3 bytes.'.format(address))
        if count > 0xffff:
            raise RuntimeError('RLE record with length {0} is too large for the IPS format. RLE records must be less than 65536 bytes.'.format(count))
        if len(data) != 1:
            raise RuntimeError('Data for RLE record must be exactly one byte! Received {0}.'.format(data))

        record = {'address': address, 'data': data, 'rle_count': count}
        self.records.append(record)

    def set_truncate_length(self, truncate_length):
        self.truncate_length = truncate_length

    def trace(self):
        print('''Start   End     Size   Data
------  ------  -----  ----''')
        for record in self.records:
            length = (record['rle_count'] if 'rle_count' in record else len(record['data']))
            data = ''
            if 'rle_count' in record:
                data = '{0} x{1}'.format(record['data'].hex(), record['rle_count'])
            elif len(record['data']) < 20:
                data = record['data'].hex()
            else:
                data = record['data'][0:24].hex() + '...'
            print('{0:06x}  {1:06x}  {2:>5}  {3}'.format(record['address'], record['address'] + length - 1, length, data))

        if self.truncate_length is not None:
            print()
            print('Truncate to {0} bytes'.format(self.truncate_length))

    def encode(self):
        encoded_bytes = bytearray()

        encoded_bytes += 'PATCH'.encode('ascii')

        for record in self.records:
            encoded_bytes += record['address'].to_bytes(3, byteorder='big')
            if 'rle_count' in record:
                encoded_bytes += (0).to_bytes(2, byteorder='big')
                encoded_bytes += record['rle_count'].to_bytes(2, byteorder='big')
            else:
                encoded_bytes += len(record['data']).to_bytes(2, byteorder='big')
            encoded_bytes += record['data']

        encoded_bytes += 'EOF'.encode('ascii')

        if self.truncate_length is not None:
            encoded_bytes += self.truncate_length.to_bytes(3, byteorder='big')

        return encoded_bytes

    def apply(self, in_data):
        out_data = bytearray(in_data)

        for record in self.records:
            if record['address'] >= len(out_data):
                out_data += bytes([0] * (record['address'] - len(out_data) + 1))

            if 'rle_count' in record:
                out_data[record['address'] : record['address'] + record['rle_count']] = b''.join([record['data']] * record['rle_count'])
            else:
                out_data[record['address'] : record['address'] + len(record['data'])] = record['data']

        if self.truncate_length is not None:
            out_data = out_data[:self.truncate_length]

        return out_data

import argparse
import sys

def cmd_apply(args):
    patch = Patch.load(args.ips_file)

    in_file = None
    with open(args.in_file, 'rb') as f:
        in_file = f.read()

    out_file = patch.apply(in_file)

    if 'out_file' in args:
        with open(args.out_file, 'w+b') as f:
            f.write(out_file)
    else:
        sys.stdout.buffer.write(out_file)

def cmd_trace(args):
    patch = Patch.load(args.ips_file)
    patch.trace()

def cmd_create(args):
    source_file = None
    target_file = None
    with open(args.source_file, 'rb') as f:
        source_file = f.read()
    with open(args.target_file, 'rb') as f:
        target_file = f.read()

    patch = Patch.create(source_file, target_file)

    if args.out_file is not None:
        with open(args.out_file, 'w+b') as f:
            f.write(patch.encode())
    else:
        sys.stdout.buffer.write(patch.encode())

def main():
    parser = argparse.ArgumentParser()
    parser.prog = 'ips_util'
    parser.description = 'Utilities for working with IPS (International Patching System) patch files.'

    subparsers = parser.add_subparsers(help='Specify a command.')

    # Workaround for https://bugs.python.org/issue9253
    subparsers.required = True
    subparsers.dest = 'command'

    apply_parser = subparsers.add_parser('apply', help='Apply a patch to a file.')

    apply_parser.add_argument('ips_file', help='The IPS file containing the patch to be applied.')
    apply_parser.add_argument('in_file', help='The file to apply the patch to.')
    apply_parser.add_argument('--output', '-o', dest='out_file', help='The file to write the patched data to. If not specified, the patched data will be sent to stdout.')
    apply_parser.set_defaults(func=cmd_apply)

    trace_parser = subparsers.add_parser('trace', help='Trace the contents of a patch file.')
    trace_parser.add_argument('ips_file', help='The IPS file containing the patch to be traced.')
    trace_parser.set_defaults(func=cmd_trace)

    create_parser = subparsers.add_parser('create', help='Create a patch file based on differences between a source and target file.')
    create_parser.add_argument('source_file', help="The original, unpatched file.")
    create_parser.add_argument('target_file', help="The file containing differences from the original from which a patch should be created.")
    create_parser.add_argument('--output', '-o', dest='out_file', help='The file to which the patch should be written. If not specified, the patch will be sent to stdout.')
    create_parser.set_defaults(func=cmd_create)

    args = parser.parse_args()
    args.func(args)

if __name__ == '__main__':
    main()
