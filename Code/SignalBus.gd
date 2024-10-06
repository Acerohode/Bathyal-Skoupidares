extends Node


# abilities
signal steal_from_opponent (magnitude: int)
signal buff (period: int, magnitude:int)
signal shield(period: int)
signal scavenge(magnitude : int)
signal steal_chunks (magnitude : int)
signal discard()

# abilities extra
signal give(how_much:int)


# global meat
signal global_gain(amount:int)
signal global_loss(amount:int)

signal meat_check(amount:int)

# extra
signal turn_done()
