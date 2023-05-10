#| label: setup
#| message: false
#| warning: false
library(metacore)  # CRAN v0.1.1
library(tidyverse) # CRAN v1.3.2
library(haven)     # CRAN v2.5.1
library(metatools) # CRAN v0.1.3
library(xportr)    # CRAN v0.1.0

file_load  <- function(url, file, ext) {
	download.file(url = url, destfile = paste0(file, ".", ext), mode = "wb", quiet = TRUE)
}

# Location of files for this walkthrough
specs_url <- "https://github.com/pharmaverse/r-pharma2022/blob/main/specs/specs.xlsx?raw=true"
dm_url <- "https://github.com/pharmaverse/r-pharma2022/blob/main/datasets/SDTM/dm.xpt?raw=true"
vs_url <- "https://github.com/pharmaverse/r-pharma2022/blob/main/datasets/SDTM/vs.xpt?raw=true"
ex_url <- "https://github.com/pharmaverse/r-pharma2022/raw/main/datasets/SDTM/ex.xpt"
sv_url <- "https://github.com/pharmaverse/r-pharma2022/blob/main/datasets/SDTM/sv.xpt?raw=true"
ae_url <- "https://github.com/pharmaverse/r-pharma2022/blob/main/datasets/SDTM/ae.xpt?raw=true"


#| label: read-spec
specs <- file_load(specs_url, "specs", "xlsx")
metacore <- spec_to_metacore("specs.xlsx", where_sep_sheet = FALSE)


#| label: read-sdtm
dm <- file_load(dm_url, "dm", "xpt")
dm <- read_xpt("dm.xpt")


#| label: select-adsl
adsl_spec <- metacore %>% 
  select_dataset("ADSL")

adsl_spec


#| label: derived-fns
# Pull together all the predecessor variables 
adsl_pred <- build_from_derived(adsl_spec,
                                ds_list = list("dm" = dm),
                                keep = TRUE) %>% # Keep old name
  filter(ARMCD %in% c("A", "P")) # Filter out anything with ARM codes other than placebo or active

head(adsl_pred)


#| label: sexn-get
get_control_term(adsl_spec, SEXN)


#| label: sexn-create
adsl_pred %>%  
  create_var_from_codelist(adsl_spec, SEX, SEXN) %>% 
  select(USUBJID, SEX, SEXN)


#| label: create-all-vars
adsl_decode <- adsl_pred %>%  
  create_var_from_codelist(adsl_spec, SEX, SEXN) %>% 
  create_var_from_codelist(adsl_spec, ETHNIC, ETHNICN) %>% 
  create_var_from_codelist(adsl_spec, RACE, RACEN) %>% 
  create_var_from_codelist(adsl_spec, COUNTRY, ACOUNTRY) %>%
  create_var_from_codelist(adsl_spec, ARMCD, TRT01PN) %>% 
  create_var_from_codelist(adsl_spec, ACTARMCD, TRT01AN) %>%
  create_var_from_codelist(adsl_spec, ARMCD, TRT01P) %>% 
  create_var_from_codelist(adsl_spec, ACTARMCD, TRT01A)

#| label: create-age-vars
get_control_term(adsl_spec, AGEGR1) # See age group categories

adsl_decode %>% 
  create_cat_var(adsl_spec, AGE, AGEGR1, AGEGR1N) %>% 
  select(USUBJID, AGE, AGEGR1, AGEGR1N) %>% 
  head()

adsl <- adsl_decode %>% 
  create_cat_var(adsl_spec, AGE, AGEGR1, AGEGR1N)
