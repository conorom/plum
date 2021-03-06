module Hyrax
  class DownloadsController < ApplicationController
    include Hyrax::DownloadBehavior

    protected

      def authorize_download!
        case params[:file]
        when "gray-pdf"
          authorize! :pdf, asset
        when "color-pdf"
          authorize! :color_pdf, asset
        when "thumbnail"
          authorize_thumbnail(asset)
        else
          authorize! :download, asset
        end
      end

    private

      # Allow all thumnbnail downloads if asset is a geo file set, otherwise authorize as a regular download
      def authorize_thumbnail(asset)
        authorize!(:download, asset) unless asset.respond_to?(:geo_mime_type) && !asset.geo_mime_type.blank?
      end

      def load_file
        file_reference = params[:file]
        return default_file unless file_reference

        file_path = PairtreeDerivativePath.derivative_path_for_reference(asset, file_reference)
        File.exist?(file_path) ? file_path : nil
      end

      def default_file
        File.exist?(asset.local_file) ? asset.local_file : super
      end
  end
end
