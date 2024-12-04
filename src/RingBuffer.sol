pragma solidity ^0.8.18;

struct RingBuffer10 {
    uint256[10] items;
    uint8 start;
    uint8 end;
    uint8 size;
}

using RingBufferLib for RingBuffer10 global;

library RingBufferLib {
    error RingBufferLengthMismatch(uint256 expected, uint256 actual);

    function append(RingBuffer10 storage buffer, uint256 value) internal {
        buffer.items[buffer.end] = value;
        buffer.end = (buffer.end + 1) % uint8(buffer.items.length);

        if (buffer.size < buffer.items.length) {
            buffer.size += 1;
        } else {
            buffer.start = (buffer.start + 1) % uint8(buffer.items.length);
        }
    }

    function getItem(
        RingBuffer10 storage buffer,
        uint256 index
    ) internal view returns (uint256) {
        return buffer.items[(buffer.start + index) % buffer.items.length];
    }

    function getItem(
        RingBuffer10 memory buffer,
        uint256 index
    ) internal pure returns (uint256) {
        return buffer.items[(buffer.start + index) % buffer.items.length];
    }

    function update(
        RingBuffer10 storage buffer,
        RingBuffer10 memory newBuffer
    ) internal {
        if (buffer.items.length != newBuffer.items.length) {
            revert RingBufferLengthMismatch(
                buffer.items.length,
                newBuffer.items.length
            );
        }

        buffer.start = newBuffer.start;
        buffer.end = newBuffer.end;
        buffer.size = newBuffer.size;

        for (uint256 i = 0; i < buffer.items.length; i++) {
            buffer.items[i] = newBuffer.items[i];
        }
    }
}
