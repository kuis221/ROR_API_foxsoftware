::SecureHeaders::Configuration.configure do |config|
    config.hsts = {:max_age => 20.years.to_i, :include_subdomains => true}
    config.x_frame_options = 'DENY'
    config.x_content_type_options = "nosniff"
    config.x_xss_protection = {:value => 1, :mode => 'block'}
    config.x_download_options = 'noopen'
    config.x_permitted_cross_domain_policies = 'none'
    config.csp = {
        :default_src => "https: self",
        :frame_src => "https: http:.twimg.com http://itunes.apple.com",
        :img_src => "https:",
        :report_uri => '//example.com/uri-directive'
    }
    config.hpkp = {
        :max_age => 60.days.to_i,
        :include_subdomains => true,
        :report_uri => '//example.com/uri-directive',
        :pins => [
            {:sha256 => 'TODO 1'},
            {:sha256 => 'TODO 2'}
        ]
    }
end