# -*- encoding : utf-8 -*-
class String
  def -(s)
    self.gsub(s, "")
  end
end
# Akismet
#
# Author:: David Czarnecki
# Copyright:: Copyright (c) 2005 - David Czarnecki
# License:: BSD
# Modified by Dieter Komendera, Sparkling Studios:
#   append blog= to data string (Akismet said it is required)
#   changed require 'net/HTTP' to require 'net/http' (to work for me unter GNU/Linux)
class Akismet

  require 'net/http'
  require 'uri'

  STANDARD_HEADERS = {
    'User-Agent' => 'Akismet Ruby API/1.0',
    'Content-Type' => 'application/x-www-form-urlencoded'
  }

  # Instance variables
  @apiKey
  @blog
  @verifiedKey
  @proxyPort = nil
  @proxyHost = nil

  # Create a new instance of the Akismet class
  #
  # apiKey
  #   Your Akismet API key
  # blog
  #   The blog associated with your api key
  def initialize(apiKey, blog)
    @apiKey = apiKey
    @blog = blog
    @verifiedKey = false
  end

  # Set proxy information
  #
  # proxyHost
  #   Hostname for the proxy to use
  # proxyPort
  #   Port for the proxy
  def setProxy(proxyHost, proxyPort)
    @proxyPort = proxyPort
    @proxyHost = proxyHost
  end

  # Call to check and verify your API key. You may then call the #hasVerifiedKey method to see if your key has been validated.
  def verifyAPIKey()
    http = Net::HTTP.new('rest.akismet.com', 80, @proxyHost, @proxyPort)
    path = '/1.1/verify-key'

    data="key=#{@apiKey}&blog=#{@blog}"

    resp, data = http.post(path, data, STANDARD_HEADERS)
    @verifiedKey = (data == "valid")
  end

  # Returns <tt>true</tt> if the API key has been verified, <tt>false</tt> otherwise
  def hasVerifiedKey()
    return @verifiedKey
  end

  # Internal call to Akismet. Prepares the data for posting to the Akismet service.
  #
  # akismet_function
  #   The Akismet function that should be called
  # user_ip (required)
  #    IP address of the comment submitter.
  # user_agent (required)
  #    User agent information.
  # referrer (note spelling)
  #    The content of the HTTP_REFERER header should be sent here.
  # permalink
  #    The permanent location of the entry the comment was submitted to.
  # comment_type
  #    May be blank, comment, trackback, pingback, or a made up value like "registration".
  # comment_author
  #    Submitted name with the comment
  # comment_author_email
  #    Submitted email address
  # comment_author_url
  #    Commenter URL.
  # comment_content
  #    The content that was submitted.
  # Other server enviroment variables
  #    In PHP there is an array of enviroment variables called $_SERVER which contains information about the web server itself as well as a key/value for every HTTP header sent with the request. This data is highly useful to Akismet as how the submited content interacts with the server can be very telling, so please include as much information as possible.
  def callAkismet(akismet_function, user_ip, user_agent, referrer, permalink, comment_type, comment_author, comment_author_email, comment_author_url, comment_content, other)
    http = Net::HTTP.new("#{@apiKey}.rest.akismet.com", 80, @proxyHost, @proxyPort)
    path = "/1.1/#{akismet_function}"

    data = "blog=#{@blog}&user_ip=#{user_ip}&user_agent=#{user_agent}&referrer=#{referrer}&permalink=#{permalink}&comment_type=#{comment_type}&comment_author=#{comment_author}&comment_author_email=#{comment_author_email}&comment_author_url=#{comment_author_url}&comment_content=#{comment_content}"
    if (other != nil)
      other.each_pair {|key, value| data.concat("&#{key}=#{value}")}
    end

    resp, data = http.post(path, data, STANDARD_HEADERS)

    return (data != "false")
  end

  protected :callAkismet

  # This is basically the core of everything. This call takes a number of arguments and characteristics about the submitted content and then returns a thumbs up or thumbs down. Almost everything is optional, but performance can drop dramatically if you exclude certain elements.
  #
  # user_ip (required)
  #    IP address of the comment submitter.
  # user_agent (required)
  #    User agent information.
  # referrer (note spelling)
  #    The content of the HTTP_REFERER header should be sent here.
  # permalink
  #    The permanent location of the entry the comment was submitted to.
  # comment_type
  #    May be blank, comment, trackback, pingback, or a made up value like "registration".
  # comment_author
  #    Submitted name with the comment
  # comment_author_email
  #    Submitted email address
  # comment_author_url
  #    Commenter URL.
  # comment_content
  #    The content that was submitted.
  # Other server enviroment variables
  #    In PHP there is an array of enviroment variables called $_SERVER which contains information about the web server itself as well as a key/value for every HTTP header sent with the request. This data is highly useful to Akismet as how the submited content interacts with the server can be very telling, so please include as much information as possible.
  def commentCheck(user_ip, user_agent, referrer, permalink, comment_type, comment_author, comment_author_email, comment_author_url, comment_content, other)
    return callAkismet('comment-check', user_ip, user_agent, referrer, permalink, comment_type, comment_author, comment_author_email, comment_author_url, comment_content, other)
  end

  # This call is for submitting comments that weren't marked as spam but should have been. It takes identical arguments as comment check.
  # The call parameters are the same as for the #commentCheck method.
  def submitSpam(user_ip, user_agent, referrer, permalink, comment_type, comment_author, comment_author_email, comment_author_url, comment_content, other)
    callAkismet('submit-spam', user_ip, user_agent, referrer, permalink, comment_type, comment_author, comment_author_email, comment_author_url, comment_content, other)
  end

  # This call is intended for the marking of false positives, things that were incorrectly marked as spam. It takes identical arguments as comment check and submit spam.
  # The call parameters are the same as for the #commentCheck method.
  def submitHam(user_ip, user_agent, referrer, permalink, comment_type, comment_author, comment_author_email, comment_author_url, comment_content, other)
    callAkismet('submit-ham', user_ip, user_agent, referrer, permalink, comment_type, comment_author, comment_author_email, comment_author_url, comment_content, other)
  end
end
class CmsBase < ActionController::Base
  protect_from_forgery
  USING_FB = false

  #SimpleForm.wrapper_class  = "group"
  #SimpleForm.label_class    = "label"

  # Activar en site_controller, es para la traducción de contenido
  before_filter :lang_init, :user_login

  helper_method :custom_options_for_select, :ads, :menu_nav, :file_exists?, :get_meta, :set_meta, :extracto,
                :article_url, :menu_nav, :templates_list, :get_controller, :get_params, :main_nav, :main_nav_child,
                :get_translation, :seccion_articulo_path, :base_url, :strip_html, :get_comments

  protected
    def user_login

      if current_user.nil?
        session[:first_login] = true
      else
        if session[:first_login]
          session[:first_login] = false

          redirect_back_or_default "/" if defined?(redirect_back_or_default)
        end
      end

    end

    def lang_init
      I18n.locale = (session.has_key?(:lang) ? session[:lang] : I18n.default_locale )
      session[:lang] = I18n.locale
    end

    def seccion_articulo_path(section, item)
      tree = []
      str = ''
      tree << section.to_param
      while !section.root?
        section = section.parent
        tree << section.to_param
      end
      tree = tree.reverse
      tree.each do |i|
        str << "/#{i}"
      end
      return "#{str}/#{item.to_param}"
    end

    def get_translation(item, lang)
      rtn = item.translations.first(:conditions => {:locale => lang})

      return rtn unless rtn.blank?

      return item.translations.build(:locale => lang)

    end
    def prepare_translations(item, item_translations_key)
      item_translations = []

      if item.has_key?(item_translations_key)
        item_translations = item[item_translations_key]
        item.delete(item_translations_key)
      end

      return item_translations
    end

    def prepare_asset(item, key=:assets)
      assets = []
      if item.has_key?(key)
        item[key].each do |k, i|
          assets << i
        end
        item.delete(key)
      end
      return assets
    end

    def save_asset(item, assets, key=:assets)
      if item.has_attribute?(key)
        item[key].each do |i|
          i.destroy
        end
      end

      if assets.length > 0
        assets.each do |i|
          puts "Contenido asset params: #{i.inspect}"
          a = Asset.new(i)
          a.item_type = item.class.to_s
          a.item_id = item.id
          a.save(:validate => false)
        end
      end
    end

    def get_params(link)
      Rails.application.routes.recognize_path(link, :method => :get)
    end
    def get_controller(link)
      get_params(link)[:controller]
    end

    def get_comments(article)
      article.comment_threads
    end

    def main_nav(sections)
      rt = ""
      sections.each do |i|
        rt << "<li>"
        config = {}
        curr_section = nil
        begin
          curr_section = params.has_key?(:id) ? Section.find(params[:id]) : nil
        rescue
          curr_section = Article.find(:first, params[:id]) if curr_section.nil?
          curr_section = curr_section.section if curr_section.class == Article
        end



        config[:class] = "current" if !curr_section.nil? && (i.respond_to?("root") ? (get_params(seccion_path(i))[:id] == curr_section.root.to_param) : false)

        rt << "#{self.class.helpers.link_to i.title, seccion_path(i), config}"

        if i.menu_show_childrens
          rt << "<ul>"
          i.articles.status_published.each do |a|
            rt << "<li><a href=\"#{seccion_articulo_path(i, a)}\">#{a.title}</a></li>"
          end
          rt << "</ul>\r"
        end
        rt << "</li>\r"
      end
      return self.class.helpers.raw rt
    end
    def main_nav_child(sections)
      rt = ""

      sections.each do |i|
        i = i[0] if i.class == Array

        config = {}

        config[:class] = "current" if params.has_key?(:section) && params[:section] == get_params(seccion_path(i))[:id]
        config[:class] = "current" if params[:id] == get_params(seccion_path(i))[:id]


rt <<
'       <li class="dropDown">
            '+ self.class.helpers.link_to( i.title, seccion_path(i), config ) +'
'
        if i.menu_show_childrens && i.children.status_visible.size > 0
rt <<
'
				    <ul>
'
          i.children.status_visible.each do |a|
rt <<
'
                <li>'+ self.class.helpers.link_to( a.title, seccion_articulo_path(i, a) ) +'</li>
'
          end
rt <<
'
				    </ul>
'
        end
rt <<
'
			</li><!-- dropdown -->
'
      end

      return self.class.helpers.raw rt
    end
    # MENU NAV FORMAT
    def menu_nav(title, link, config={})

      # DEFAULTS
      config[:current] = ["class", "current"] unless config.has_key?(:current)
      config[:valid] = "unset" unless config.has_key?(:valid)
      config[:check_id] = false unless config.has_key?(:check_id)
      config[:condition] = nil unless config.has_key?(:condition)
      config[:class] = "" unless config.has_key?(:class)
      config[:current_tag] ||= "li"

      # LINK PARSE
      inf = get_controller link

      valid = false
      if config[:valid] == "unset" && params[:controller] == inf[:controller]
        valid = true

        if config[:check_id] && valid == true
          if (config[:check_id] == true && params[:id] == inf[:id]) || config[:condition]
            valid = true
        else
            valid = false
          end
        end
      end

      current_str = ""

      if config[:current][0] == "class"
        config[:class] += (config[:class].length > 0 ? ' ' : '') + config[:current][1] if valid
      else
        current_str += " #{config[:current][0]}=\"#{config[:current][1]}\" " if valid
      end

      current_str += " class=\"#{config[:class]}\" " if config[:class].length > 0

      str = ""

      str += "<#{config[:current_tag]}#{current_str}>" if config[:current_tag] != "a"

      str += "<a href=\"#{link}\""

      str += current_str if config[:current_tag] == "a"

      str += ">#{title}</a>"

      str += "</#{config[:current_tag]}>" if config[:current_tag] != "a"

      return str
    end

    # SITE BREADCRUMBS
    def breadcrumb(data_arr)
      symb = "&raquo;"
      txt = '<div id="breadcrumb">'
      txt += (link_to 'Listas', lists_path)
      for i in data_arr
        if i.is_a? String
          txt += " #{symb} #{i}"
        else
          txt += " #{symb} <a href=\"#{i[:link]}\">#{i[:title]}</a>"
        end
      end
      txt += '</div>'
      return txt
    end

    def breadcrumb_admin(data_arr)
      symb = "&raquo;"
      txt = '<div id="breadcrumb">'
      txt += "<a href=\"#{admin_root_path}\">Administrador</a>"
      for i in data_arr
        if i.is_a? String
          txt += " #{symb} #{i}"
        else
          txt += " #{symb} <a href=\"#{i[:link]}\">#{i[:title]}</a>"
        end
      end
      txt += '</div>'
      return txt
    end

    def add_breadcrumb name, url = ''
      @breadcrumbs ||= []
      url = eval(url) if url =~ /_path|_url|@/
      @breadcrumbs << [name, url]
    end

    def self.add_breadcrumb name, url, options = {}
      before_filter options do |controller|
        controller.send(:add_breadcrumb, name, url)
      end
    end

    # NAVIGATION HISTORY
    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default="/")
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    # USER FUNCTIONS
    def fetch_logged_in_user
      if USING_FB
        if !current_user.nil? && current_user.facebook_session
          @current_user = User.find_by_fb_user(facebook_session.user)
          current_user_role
        else
          return unless session[:user_id]
          @current_user = User.find_by_id(session[:user_id])
          current_user_role
        end
      end
    end

    def current_user_role
      return nil if @current_user.nil?
      return @current_user_role if defined?(@current_user_role)
      if current_user.role.nil?
        UserRole.new(:user_id => current_user.id, :role_id => 2).save
      end
      @current_user_role = current_user.role
    end

    # USER REQUIRES
    def require_user
      unless current_user
        store_location
        flash[:notice] = t(:necesitas_estar_conectado).nil? ? "You must be logged in to access this page" : t(:necesitas_estar_conectado)
        redirect_to new_user_session_url
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:notice] = "You must be logged out to access this page"
        redirect_back_or_default(root_path)
        return false
      end
    end

    def require_admin
      if current_user.nil?
        store_location
        flash[:notice] = "Debes estar conectado para poder ingresar"
        redirect_to login_path
        return false
      else
        if !current_user_role.nil? && current_user_role.login_as_admin
          return true
        else
          flash[:notice] = "No tienes permisos para ingresar al administrador"
          redirect_back_or_default root_path
          return false
        end
      end

    end

    def is_admin?(user)
      if !user.role.nil? && user.role.login_as_admin
        return true
      end
      return false
    end

    # ARTICLES
    def content_excerpt(content)
      str = content.split('<!-- pagebreak -->')[0]
      if str.length > 1
        str[str.length-4, str.length-1] = str[str.length-4, str.length-1].gsub("<p>", "")
      else
        str = content
      end
      return str
    end

    def extracto(text1, text2="", length=100)
      coder = HTMLEntities.new
      text1 = coder.decode(text1)
      text2 = coder.decode(text2)

      text = ""
      if !text2.blank? && text2.length > 0
        text = text2
      else
        text = text1 unless text1.blank?
      end
      ntext = text.gsub(/<\/?.*?>/, "")[0..length]
      ntext += "..." if text.length > length

      return ntext.gsub("<p>", "")
    end

    # SPAM FILTER
    def check_comment_for_spam(author, text)
      @akismet = Akismet.new('654875f91529', 'http://andres.villagranquiroz.cl') # blog url: e.g. http://sas.sparklingstudios.com

      # return true when API key isn't valid, YOUR FAULT!!
      return true unless @akismet.verifyAPIKey

      # will return false, when everthing is ok and true when Akismet thinks the comment is spam.
      return @akismet.commentCheck(
          request.remote_ip, # remote IP
          request.user_agent, # user agent
          request.env['HTTP_REFERER'], # http referer
          '', # permalink
          'comment', # comment type
          author, # author name
          '', # author email
          '', # author url
          text, # comment text
          {}) # other
    end

    def templates_list
      rt = []

      Dir.glob(RAILS_ROOT + "/app/views/templates/*.html.erb").each do |i|
        rt << (i - "#{RAILS_ROOT}/")
      end

      return rt
    end

    def paypal(values = {})
      values[:development]  = false                           if !values.has_key?(:development)
      values[:email]        = 'andres@villagranquiroz.cl'     if (!values.has_key?(:email) || values[:email].length < 6)
      values[:title]        = 'Ejemplo'                       if !values.has_key?(:title)
      values[:id]           = 0                               if !values.has_key?(:id)
      values[:amount]       = 1                               if !values.has_key?(:amount)
      values[:form_id]      = "paypal_#{values[:id]}"         if !values.has_key?(:form_id)
      values[:show_button]  = true                            if !values.has_key?(:show_button)
  #   values[:ipn]          = '/paypal'                       if !values.has_key?(:ipn)
      values[:return]       = "/paypal/"                      if !values.has_key?(:return)
      values[:return_button]= "Complete your donation"        if !values.has_key?(:return_button)

      is_development        = (Rails.env.development? || values[:development] == true)

      site_url = !Rails.env.development? ? ApplicationController::SITE_URL : 'http://localhost:3000'

      button = (values[:show_button] == true) ? '<input type="image" src="https://www.' + (is_development ? 'sandbox.' : '') + 'paypal.com/en_US/i/btn/btn_donateCC_LG.gif" border="0" name="submit" alt="PayPal - The safer, easier way to pay online!">
      <img alt="" border="0" src="https://www.' + (is_development ? 'sandbox.' : '') + 'paypal.com/es_XC/i/scr/pixel.gif" width="1" height="1">' : ''


  #     <input type="hidden" name="lc" value="CL">
  #    <input type="hidden" name="cn" value="Añadir instrucciones especiales para el vendedor">
  #    + (values[:return].last == "=" ? '&' : '?') + 'item_id='+ (values[:id].to_s) +'&amount='+ (values[:amount].to_s) +'"

      return '
  <form id="'+ values[:form_id] +'" action="https://www.' + (is_development ? 'sandbox.' : '') + 'paypal.com/cgi-bin/webscr" method="post">
      <input type="hidden" name="cmd" value="_donations">
      <input type="hidden" name="business" value="'+ values[:email] +'">
      <input type="hidden" name="item_name" value="'+ values[:title] +'">
      <input type="hidden" name="item_number" value="'+ (values[:id].to_s) +'">
      <input type="hidden" name="amount" value="'+ (values[:amount].to_s)  +'">
      <input type="hidden" name="currency_code" value="USD">
      <input type="hidden" name="no_note" value="0">
      <input type="hidden" name="no_shipping" value="1">
      <input type="hidden" name="rm" value="2">
      <input type="hidden" name="return" value="' + site_url + values[:return] + 'success">
      <input type="hidden" name="cancel_return" value="'+ site_url + values[:return] + 'cancel">
      <input type="hidden" name="currency_code" value="USD">
      <input type="hidden" name="cbt" value="'+ values[:return_button] +'">
      <input type="hidden" name="bn" value="PP-DonationsBF:btn_donateCC_LG.gif:NonHosted">
      '+ button +'
      </form>'
    end

    # ENCODE
    def encode(str)
      if defined?(ActiveSupport::Inflector.parameterize)
        ActiveSupport::Inflector.parameterize(str).to_s
      else
        ActiveSupport::Multibyte::Handlers::UTF8Handler.normalize(str, :d).split(//u).reject { |e| e.length > 1 }.join.strip.gsub(/[^a-z0-9]+/i, '-').downcase.gsub(/-+$/, '')
      end
    end

    # HTML UTILS
    def custom_options_for_select(data, config={})
      if config.has_key?(:value)
        value = config[:value]
      else
        raise ":value missing on custom_options_for_select"
      end
      if config.has_key?(:key)
        key = config[:key]
      else
        key = value
      end
      selected_value = ""
      if config.has_key?(:default)
        selected_value = config[:default]
      end
      if config.has_key?(:prompt)
        data = [{key => config[:prompt], value => config[:prompt]}] + data
      end


      ret = ""
      data.each do |i|
        ret += "<option value=\"#{i[key]}\"#{i[key] == selected_value ? ' SELECTED' : ''}>#{i[value]}</option>\n"
      end
      return ret
    end

    def strip_html(text)
      return text.gsub(/<\/?[^>]*>/, "")
    end

    # IMAGES UTILS
    def save_images(item)
      if params.has_key?(:images)
        images = params[:images]
        images.each_key do |k|
          img_file = images[k]["uploaded_data"]
          if File.extname(img_file.original_filename) == ".zip"
            name =  img_file.original_filename
            directory = "public/unzip"
            path = File.join(directory, name)
            File.open(path, "wb") { |f| f.write(img_file.read) }

            unzip_file(path, "#{RAILS_ROOT}/public/unzip", item)

            File.delete(path) if File.exist?(path)
          else
            image = Image.new(images[k])
            image.item_type = item.class.to_s
            image.item_id = item.id
            image.save
          end
        end
      end

      if params.has_key?(:image_highlighted)
        item.images.each do |i|
          if i.id.to_s == params[:image_highlighted]
            i.update_attribute :highlighted, true
            logger.info "UPDATE ATTRIBUTE #{i.id}: true"
          else
            i.update_attribute :highlighted, false
            logger.info "UPDATE ATTRIBUTE #{i.id}: false"
          end
        end
      end

      if params.has_key?(:image_description)
        item.images.each do |i|
          if params[:image_description].has_key?(i.id.to_s)
            i.update_attribute(:description, params[:image_description][i.id.to_s])
          end
        end
      end
    end

    def images_destroy(item=nil)
      if params.has_key?(:images_list)
        imgs = params[:images_list]
        imgs.each_key do |k|
          img = Image.find(k)
          img.delete
        end
      end
      unless item.nil?
        begin
          if !item.image.nil?
            item.image.destroy
          end
        rescue
        end
        begin
          if !item.images.nil?
            item.images.each do |i|
              i.destroy
            end
          end
        rescue
        end
      end
    end

    def unzip_file(source, target, item)
      # Create the target directory.
      # We'll ignore the error scenario where
      begin
        Dir.mkdir(target) unless File.exists? target
      end


      Zip::ZipFile.open(source) do |zipfile|
        dir = zipfile.dir

        dir.entries('.').each do |entry|
          unless entry == "__MACOSX"
            zipfile.extract(entry, "#{target}/#{entry}")

            path = "#{target}/#{entry}"
            p = Image.new(:uploaded_data => LocalFile.new(path))
            p.item_type = item.class.to_s
            p.item_id = item.id
            p.save

            File.delete(path)

          end

        end
      end
    end

    # SOCIALES Y METADATOS
    # Necesita gem sanitize
    def set_meta(config = {})
      @meta = {} if @meta.blank?

      config.each do |k, i|
        unless i.nil?
          i = i.gsub(/<\/?[^>]*>/,  "")
          @meta[k] = i[0..200]+(i.length > 200 ? "..." : "")
        end
      end

    end
    def get_meta(config = {})
      # defaults
      @meta = {} if @meta.blank?

      site_name = config.has_key?(:site_name) ? config[:site_name] : "[SiteName]"
      config[:include_host] = false   unless config.has_key?(:include_host)

      title = ""
      if @meta.has_key?(:title)
        title = @meta[:title]
      end
      if config.has_key?(:app_id)
        @meta[:app_id] = config[:app_id]
      end

      ret = ""

      ret += "<title>" + (title != "" ? "#{CGI::escapeHTML(title)} en " : CGI::escapeHTML(title) ) + site_name +"</title>\n"

      if @meta.has_key?(:description)
  		  ret += "\t"+'<meta name="description" content="' + CGI::escapeHTML(@meta[:description]) + '" />' + "\n"
  		end

  		ret += "\t"+'<meta property="og:title" content="' + (!@meta[:title].blank? ? CGI::escapeHTML(@meta[:title]) : site_name) + '"/>' + "\n"

      ret += "\t"+'<meta property="og:url" content="' + (config[:include_host] ? base_url : '') + @meta[:url] + '" />' + "\n" if @meta.has_key?(:url)

      ret += "\t"+'<meta property="og:site_name" content="' + site_name +'"/>' + "\n"

      if @meta.has_key?(:type)
  		  ret += "\t"+'<meta property="og:type" content="' + CGI::escapeHTML(@meta[:type]) + '"/>' + "\n"
  		end

  		if @meta.has_key?(:image)
  		  ret += "\t"+'<meta property="og:image" content="' + (config[:include_host] ? base_url : '') + @meta[:image] + '"/>' + "\n"
  		end
  		if @meta.has_key?(:description)
  		  ret += "\t"+'<meta property="og:description" content="' + CGI::escapeHTML(@meta[:description]) + '"/>' + "\n"
  		end
  		if @meta.has_key?(:app_id)
  		  ret += "\t"+'<meta property="fb:app_id" content="' + @meta[:app_id] + '"/>' + "\n"
  	  end

      return ret
    end

    def base_url
      return "http://#{request.host}"
    end

end
