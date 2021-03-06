module Workflow
  class PlumWorkflowStrategy
    attr_reader :work

    def initialize(work)
      @work = work
    end

    # @return [String] The name of the workflow to use
    def workflow
      return Sipity::Workflow.where(name: 'book_works').first! if book_works.include? work_class
      return Sipity::Workflow.where(name: 'folder_works').first! if folder_works.include? work_class
      return Sipity::Workflow.where(name: 'ephemera_box_works').first! if box_works.include? work_class
      return Sipity::Workflow.where(name: 'geo_works').first! if geo_works.include? work_class
    end

    private

      def work_class
        work.class.to_s
      end

      def book_works
        %w(ScannedResource MultiVolumeWork)
      end

      def box_works
        %w(EphemeraBox)
      end

      def folder_works
        %w(EphemeraFolder)
      end

      def geo_works
        %w(ImageWork VectorWork RasterWork MapSet)
      end
  end
end
