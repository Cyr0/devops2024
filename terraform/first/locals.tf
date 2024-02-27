locals {
  current_timestamp = timestamp()
  formatted_timestamp = formatdate("DD-MM-YYYY'T'hh:mm:ss'Z'", local.current_timestamp)
  custom_formatted_timestamp = replace(local.formatted_timestamp, "T", "-")
  custom_formatted_timestamp_s = replace(local.formatted_timestamp, ":", "-")
  final_formatted_timestamp = replace(local.custom_formatted_timestamp, "Z", "")
}
