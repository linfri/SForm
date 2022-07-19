# SForm

SForm is an easy-to-use music submission form (R Shiny app + additional R scripts), which uploads music files to [Dropbox](https://www.dropbox.com) along with the form data (artist name, track title, country, and artist's website), downloads the files locally, renames the files according to the form data, transforms the data and generates text files + statistics based on the data. Intended for music compilation producers and [netlabel](https://en.wikipedia.org/wiki/Netlabel) owners collecting single tracks from many different sources. Supports [GDPR](https://gdpr.eu) (disabled by default). Optimized for [Bandcamp](https://bandcamp.com) and, specifically, the submission requirements of [Kalamine Records](http://kalaminerecords.com), but can be easily adapted for any other netlabel.

## Installation and Usage

You will need: [R](https://www.r-project.org) & [RStudio](https://www.rstudio.com), a Dropbox account and [shinyapps.io](https://www.shinyapps.io) account.

Dependencies: `shinyjs`, `shinybulma`, `rdrop2`, `lubridate`, `tools`, `R.utils`, `stringi`, `rvest`, `curl`. 

Paste your compilation call/description (HTML allowed) into `compilationcall.txt`

Paste the deadline date into `deadline.txt` (YYYY-MM-DD format)

Paste the Facebook event link (HTML) into `fbevent.txt`

Paste the producer's name (HTML allowed) into `producer.txt`

Generate the Dropbox token with `token.R`. Load the function into the environment, and run:

```r
generateToken()
```

Deploy the app according to [these instructions](https://shiny.rstudio.com/articles/shinyapps.html). 

Wait until you got submitted tracks in your Dropbox.

Open `download.R`, load all the functions into the environment, and run:

```r
downloadMusic()
```

Check the `Downloads` folder (created by default). You're done!

Don't forget to paste the name of your mastering engineer, graphic designer & photo source into your `AlbumCredits.txt`

![](app.png?raw=true)

## Roadmap

Adding support for AWS, ran into some Dropbox-specific issues.

Collecting emails and mass-mailing the artists (if GDPR is enabled).

Generating description files for Internet Archive.

Generating not only CSVs but also PDF reports with stats.

Adding checks for special symbols (if migration to AWS won't solve it)

Creating a SQL database of the artist descriptions/links for automatic generation.

## Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## License

[MIT](https://choosealicense.com/licenses/mit/)
