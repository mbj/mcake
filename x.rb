require 'mcake'

mcake = MCake.empty

target = MCake::Target.new(
  name:         MCake::Name.build(:test),
  dependencies: [],
  block:        ->() {}
)

mcake
  .add_target(target)
  .build(MCake.name(:test))
