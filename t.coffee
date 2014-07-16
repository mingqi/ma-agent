program = require 'commander'

program
  .parse(process.argv)

program
 .command('setup')
 .description('run remote setup commands')
 .action( () ->
   console.log('setup');
   console.log("this is setup"+program.config)
 );

program
  .option('-c, --config <path>', 'set config path. defaults to ./deploy.conf')

console.log program.config