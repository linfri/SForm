# SForm

SForm is an easy-to-use music submission form (R Shiny app + additional R scripts), which uploads music files to [Dropbox](https://www.dropbox.com) along with the form data (artist name, track title, country, and artist's website), downloads the files locally, renames the files according to the form data, transforms the data and generates text files + statistics (frequency tables) based on the data. Intended for music compilation producers and [netlabel](https://en.wikipedia.org/wiki/Netlabel) owners collecting single tracks from many different sources.

The text files include artist descriptions, tracklists, and the album description + credits. Supports [GDPR](https://gdpr.eu) (disabled by default). Optimized for [Bandcamp](https://bandcamp.com) and specifically for [Kalamine Records](http://kalaminerecords.com) submission process.

Created by Linn Friberg (@linfri), who is studying towards BSc with a major in Statistics at Linköping University.

## Installation and Usage

You will need: [R](https://www.r-project.org) & [RStudio](https://www.rstudio.com), a Dropbox account and [shinyapps.io](https://www.shinyapps.io) account.

Dependencies: `shinyjs`, `shinybulma`, `rdrop2`, `lubridate`, `tools`, `R.utils`, `stringi`, `rvest`, `curl`. 

If any of these packages are missing, run:

```r
install.packages("your-package-name")
```

except in case of `shinybulma`, in this case run:

```r
install.packages("devtools")
devtools::install_github("RinteRface/shinybulma")
```

Paste your compilation call/description (HTML allowed) into `compilationcall.txt`

Paste the deadline date into `deadline.txt` (YYYY-MM-DD format)

Paste the Facebook event link (HTML) into `fbevent.txt`

Paste the producer's name (HTML allowed) into `producer.txt`

Generate the Dropbox token with `token.R`:

```r
generateToken()
```

Deploy the app according to [these instructions](https://shiny.rstudio.com/articles/shinyapps.html). 

Open `download.R`, load all the functions into the environment, and simply run:

```r
downloadMusic()
```

Check the `Downloads` folder. You're done!

## Roadmap

Adding support for AWS, ran into some Dropbox-specific issues.
Collecting emails and mass-mailing the artists (if GDPR is enabled).
Generating description files for Internet Archive.
Generating not only CSVs but also PDF reports with stats.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License
[MIT](https://choosealicense.com/licenses/mit/)