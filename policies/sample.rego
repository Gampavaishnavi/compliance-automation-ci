package compliance

# By default, allow the build
default allow = true

# If any control result has status "failed", block the build
allow if {
  not has_failed_controls
}

has_failed_controls if {
  some p
  some c
  some r
  input.profiles[p].controls[c].results[r].status == "failed"
}

