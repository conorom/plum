class ManifestBuilder
  class ManifestHelper
    include Rails.application.routes.url_helpers
    include ActionDispatch::Routing::PolymorphicRoutes

    def default_url_options
      ActionMailer::Base.default_url_options
    end
  end
end
