


# function to find the common prefix of file paths
common_prefix <- function(strings) {
  prefix <- strings[1]
  for (str in strings[-1]) {
    while (!startsWith(str, prefix)) {
      prefix <- substr(prefix, 1, nchar(prefix) - 1)
    }
  }
  return(prefix)
}