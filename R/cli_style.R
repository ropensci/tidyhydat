# Copyright 2018 Province of British Columbia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

## drawing heavily from the tidyverse package

done <- function(msg) {
  packageStartupMessage(crayon::green(cli::symbol$tick), " ", msg)
}

not_done <- function(msg) {
  packageStartupMessage(crayon::red(cli::symbol$cross), " ", msg)
}

congrats <- function(msg) {
  packageStartupMessage(crayon::yellow(cli::symbol$star), " ", msg)
}

info <- function(msg) {
  packageStartupMessage(crayon::blue(cli::symbol$bullet), " ", msg)
}


red_message <- function(msg) {
  message(crayon::red(cli::symbol$cross), " ", msg)
}

green_message <- function(msg) {
  message(crayon::green(cli::symbol$tick), " ", msg)
}
