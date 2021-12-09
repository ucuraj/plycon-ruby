// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
//= require simple_datatables


import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"

require('./index');
require('./main');

import "bootstrap"
import "bootstrap/scss/bootstrap.scss"
import "bootstrap-icons/font/bootstrap-icons.css"
import "boxicons"
import "boxicons/css/boxicons.css"
import "quill"
import "quill/dist/quill.bubble.css"
import "quill/dist/quill.snow.css"
import "remixicon/fonts/remixicon.css"
import "simple-datatables"
import "simple-datatables/dist/style.css"
import "tinymce"
import "jquery"

import "../css/application.scss";


Rails.start()
Turbolinks.start()
ActiveStorage.start()
