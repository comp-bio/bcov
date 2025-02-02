# .BCOV

Binary Coverage data format.

A compact and simple format for storing genome coverage depth data.
Exactly 2 bytes are used to store information about the depth of reads for each position in the genome.
Thus, the format can store integer values ​​of coverage depth in the range from 0 to 65535 ([unsigned short](https://en.cppreference.com/w/cpp/types/integer)).

## How to read data from `.bcov` file:

```python
# Bytes from file:
chars = [0, 1, 0, 2, 0, 3, 0, 50, 0, 100, 3, 232, 1, 244, 1, 244, 1, 144]
# chars(HEX) = 00 01 00 02 00 03 00 32 00 64 03 e8 01 f4 01 f4
# chars(BIN) = 0100 0200 0300 3200 6400 e803 f401 f401

coverage = []
for i in range(0, len(chars), 2):
    coverage.append(chars[i] * 256 + chars[i + 1])
print("coverage: ", coverage)
# -> coverage:  [1, 2, 3, 50, 100, 1000, 500, 500, 400]
```

Example of reading a simple file `test/example.bcov`:

```bash
hexdump test/example.bcov
0000000 0100 0200 0300 3200 6400 e803 f401 f401
0000010 9001 2c01 c800 0000 0000 0000 6300 6200
```

```python
def bcov(src, start=0):
    with open(src, 'rb') as f:
        f.seek(start * 2)
        while True:
            value = f.read(2)
            if not value:
                break
            yield value[0] * 256 + value[1]

print([i for i in bcov('test/example.bcov')])
```

## How to create your own `.bcov` file

```python
coverage = [1, 2, 3, 50, 100, 1000, 500, 500, 400, 300, 200, 0, 0, 0, 99, 98]
with open('test/example.bcov', 'wb') as f:
    for cov in coverage:
        ch2 = int(cov % 256)
        ch1 = int((cov - ch2)/256)
        cnt = f.write(bytearray([ch1, ch2]))
```

## Converting `.bed` (`.bam`, `.cram`) files to `.bcov`

For quick conversion of `.bed` files, use our solution written in C.
The script automatically creates a `.bcov` file for each chromosome
from a `.bed` file:

```bash
wget https://github.com/comp-bio/bcov/raw/main/build/bed2cov_$(uname) -O ./bed2cov
chmod +x bed2cov
cat text/example.bed | ./bed2cov
```

To get the `.bed` file of the coverage from your `.bam` or `.cram` file,
use (mosdepth)[https://github.com/brentp/mosdepth].

Automated pipeline for converting .bam to .bcob:

```bash
wget https://github.com/comp-bio/bcov/raw/main/bam2bcov.sh
chmod +x bam2bcov.sh
./bam2bcov.sh src.bam
```
