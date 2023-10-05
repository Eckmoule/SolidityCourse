fn sum(a: felt252, b: felt252) -> felt252 {
    return a + b; 
}

#[test]
fn test_sum(x: felt252, y: felt252) {
    assert(sum(x, y) == x + y, 'Error');
}