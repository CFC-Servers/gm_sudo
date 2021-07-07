import random from math

class Random
    bytes: (length) ->
        string.char unpack [random(0, 255) for i = 1, length]

Random!
