
knitr::knit_engines$set(gle = function(options) {
  code <- paste(options$code, collapse = '\n')
  # dealing with defaults:
  gle_pre         <- if(is.null(options$gle_pre)) "" else options$gle_pre
  gle_gap1        <- if(is.null(options$gle_gap1)) "<br/>" else options$gle_gap1
  gle_gap2        <- if(is.null(options$gle_gap2)) "<br/>" else options$gle_gap2
  gle_post        <- if(is.null(options$gle_post)) "<br/>" else options$gle_post
  gle_dir         <- if(is.null(options$gle_dir)) "gle" else options$gle_dir  
  gle_path        <- if(Sys.getenv("gle_path") == "") "gle" else Sys.getenv("gle_path")
  gle_image_dir   <- if(is.null(options$gle_image_dir)) paste0(gle_dir, "/images") else options$gle_image_dir
  base_name       <- if(is.null(options$label)) gsub("/","", tempfile(pattern = "img_", tmpdir = "")) else options$label
  gle_show_cmd    <- if(is.null(options$gle_com)) "yes" else options$gle_com  
  chunk_titles    <- if(is.null(options$chunk_titles)) "on-on-on" else options$chunk_titles  
  gle_output_type <- if(is.null(options$gle_output_type)) "png" else options$gle_output_type
  gle_options     <- if(is.null(options$gle_options)) "" else options$gle_options
  
  com <- paste0("mkdir -p ", gle_dir)
  system(com)
  com <- paste0("mkdir -p ", gle_image_dir)
  system(com)
  
  chunk_titles <- strsplit(chunk_titles, "-")[[1]]
  gle_options  <- options$gle_options
  gle_source   <- paste0(gle_dir, "/", base_name, ".gle")
  gle_imgname  <- paste0(gle_image_dir, "/", base_name, ".", gle_output_type)
  
  cat(code, file=gle_source)
  
  gle_com <- paste0(" -d ", gle_output_type, " ", gle_options, " -output ", gle_imgname, " ", gle_source)
  gle_com_pretty <- paste0('$gle_path ', gle_com)
  gle_com_pretty <- trimws(gle_com_pretty)
  gle_com_pretty <- gsub("\\s+", " ", gle_com_pretty, perl=T)
  gle_com <- paste0(gle_path, gle_com)
  cat(gle_com,"\n")
  system(gle_com)
  
  knitr_output <- knitr::engine_output(options, code, out="")
  
  gle_code_title <- if(chunk_titles[1] == "on") paste0("GLE code saved to ", gle_source, ":\n") else ""
  gle_code_html  <- paste0(gle_pre, gle_code_title, "<pre class=\"gle_code\"><code>", code,"</code></pre>")
  
  gle_run_title  <- if(chunk_titles[2] == "on") "GLE compiled as:\n" else ""
  gle_run_html   <- paste0(gle_gap1, gle_run_title, "<pre class=\"gle_run\"><code>", gle_com_pretty,"</code></pre>")
  
  gle_img_title  <- if(chunk_titles[3] == "on") "GLE image:\n<br/>\n" else ""
  gle_img_html   <- paste0(gle_gap2, gle_img_title, "<pre class=\"gle_img\"><code><img src=\"", gle_imgname, "\"></code></pre>")
  if(gle_output_type == "pdf") gle_img_html   <- paste0(gle_gap2, gle_img_title, "<pre class=\"gle_img\"><code><embed src=\"", gle_imgname, "\" width=\"500\" type=\"application/pdf\"></code></pre>")
  
  
  my_output <- gle_code_html
  if(gle_show_cmd == "yes"){
    my_output <- c(my_output, gle_run_html)
  }
  my_output <- c(my_output, gle_img_html)
  my_output <- c(my_output, gle_post)
  my_output <- paste(my_output, sep="\n\n")
  
  my_output
})
