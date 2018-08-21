---
title: "Release Steps"
output: github_document
---

## Update `allstations` data and documentation
```
source("data-raw/HYDAT_internal_data/process_internal_data.R")
```

## Check if version is appropriate
http://shiny.andyteucher.ca/shinyapps/rver-deps/

## Build and check within `R/devtools`
```
devtools::build_win()
devtools::check() ## build locally
```

## Build and check on rhub
```
library(rhub)

check_on_debian()
check_on_windows()
check_on_ubuntu()
check_on_macos()
```

## Run this in the console
```
R CMD build tidyhydat
R CMD check tidyhydat_0.3.5.tar.gz --as-cran ## or whatever the package name is
```

## Documentation
- Update NEWS
- Update cran-comments

## Actually release it
```
devtools::release()
```

## Once it is release create signed release on github
```
git tag -s [version] -m "[version]"
git push --tags
```

```
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
```
