group "Preserve output reports" do
  target "Exits user david"
  run "id david"
  expect "david"
end

play do
  show
  export preserve: true
end
