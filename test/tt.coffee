humanFormat = require 'human-format'
a = humanFormat(2024, {
    prefixes: humanFormat.makePrefixes(
        ',m,g'.split(','),
        1024
    )
});

# console.log a


prefixes = humanFormat.makePrefixes(
        ',k,m,g'.split(','),
        1024 )


# console.log humanFormat.parse('3m', {
#     prefixes: humanFormat.makePrefixes(
#         ',m,g'.split(','),
#         1024
#     )
# })

opts = {
  unit: 'B'
  prefixes: humanFormat.makePrefixes(',K,M,G,T'.split(','), 1024 )
}

console.log  humanFormat.parse('10', opts)
console.log humanFormat(10485760, opts)