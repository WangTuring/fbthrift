#!/usr/bin/env python3
import copy
import unittest

from testing.types import SetI32Lists, SetSetI32Lists, SetI32
from typing import AbstractSet, Sequence, Any, Tuple


class SetTests(unittest.TestCase):
    def test_and(self) -> None:
        x = SetI32({1, 3, 4, 5})
        y = SetI32({1, 2, 4, 6})
        self.assertEqual(x & y, set(x) & set(y))
        self.assertEqual(y & x, set(y) & set(x))

    def test_or(self) -> None:
        x = SetI32({1, 3, 4, 5})
        y = SetI32({1, 2, 4, 6})
        self.assertEqual(x | y, set(x) | set(y))
        self.assertEqual(y | x, set(y) | set(x))

    def test_xor(self) -> None:
        x = SetI32({1, 3, 4, 5})
        y = SetI32({1, 2, 4, 6})
        self.assertEqual(x ^ y, set(x) ^ set(y))
        self.assertEqual(y ^ x, set(y) ^ set(x))

    def test_sub(self) -> None:
        x = SetI32({1, 3, 4, 5})
        y = SetI32({1, 2, 4, 6})
        self.assertEqual(x - y, set(x) - set(y))
        self.assertEqual(y - x, set(y) - set(x))

    def test_comparisons(self) -> None:
        x = SetI32({1, 2, 3, 4})
        y = SetI32({1, 2, 3})
        x2 = copy.copy(x)

        def eq(t: AbstractSet[Any], s: AbstractSet[Any]) -> Tuple[bool, ...]:
            return (t == s, set(t) == s, t == set(s), set(t) == set(s))

        def neq(t: AbstractSet[Any], s: AbstractSet[Any]) -> Tuple[bool, ...]:
            return (t != s, set(t) != s, t != set(s), set(t) != set(s))

        def lt(t: AbstractSet[Any], s: AbstractSet[Any]) -> Tuple[bool, ...]:
            return (t < s, set(t) < s, t < set(s), set(t) < set(s))

        def gt(t: AbstractSet[Any], s: AbstractSet[Any]) -> Tuple[bool, ...]:
            return (t > s, set(t) > s, t > set(s), set(t) > set(s))

        def le(t: AbstractSet[Any], s: AbstractSet[Any]) -> Tuple[bool, ...]:
            return (t <= s, set(t) <= s, t <= set(s), set(t) <= set(s))

        def ge(t: AbstractSet[Any], s: AbstractSet[Any]) -> Tuple[bool, ...]:
            return (t >= s, set(t) >= s, t >= set(s), set(t) >= set(s))

        # = and != testing
        self.assertTrue(all(eq(x, x2)))
        self.assertTrue(all(neq(x, y)))
        self.assertFalse(any(eq(x, y)))
        self.assertFalse(any(neq(x, x2)))

        # lt
        self.assertTrue(all(lt(y, x)))
        self.assertFalse(any(lt(x, y)))
        self.assertFalse(any(lt(x, x2)))

        # gt
        self.assertTrue(all(gt(x, y)))
        self.assertFalse(any(gt(y, x)))
        self.assertFalse(any(gt(x, x2)))

        # le
        self.assertTrue(all(le(y, x)))
        self.assertFalse(any(le(x, y)))
        self.assertTrue(all(le(x, x2)))

        # ge
        self.assertTrue(all(ge(x, y)))
        self.assertFalse(any(ge(y, x)))
        self.assertTrue(all(ge(x, x2)))

    def test_None(self) -> None:
        with self.assertRaises(TypeError):
            SetI32Lists({None})  # type: ignore
        with self.assertRaises(TypeError):
            SetSetI32Lists({{None}})  # type: ignore

    def test_empty(self) -> None:
        SetI32Lists(set())
        SetI32Lists({()})
        SetSetI32Lists(set())
        SetSetI32Lists({SetI32Lists()})
        SetSetI32Lists({SetI32Lists({()})})

    def test_mixed_construction(self) -> None:
        x = SetI32Lists({(0, 1, 2), (3, 4, 5)})
        z = SetSetI32Lists({x})
        pz = set(z)
        pz.add(x)
        nx: AbstractSet[Sequence[int]] = {(9, 10, 11)}
        pz.add(SetI32Lists(nx))
        cz = SetSetI32Lists(pz)
        self.assertIn(nx, cz)
        pz.add(5)  # type: ignore
        with self.assertRaises(TypeError):
            SetSetI32Lists(pz)

    def test_hashability(self) -> None:
        hash(SetI32Lists())
        z = SetSetI32Lists({SetI32Lists({(1, 2, 3)})})
        hash(z)
        for sub_set in z:
            hash(sub_set)
