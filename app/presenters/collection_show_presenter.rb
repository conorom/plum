class CollectionShowPresenter < CurationConcerns::CollectionPresenter
  include CurationConcerns::Serializers
  delegate :id, :title, :exhibit_id, :date_created, to: :solr_document, allow_nil: true

  delegate :title, :description, :creator, :contributor, :subject, :publisher, :language,
           :embargo_release_date, :lease_expiration_date, :rights, to: :solr_document,
                                                                   allow_nil: true

  def member_presenters
    @member_presenters ||= CurationConcerns::PresenterFactory.build_presenters(ordered_ids,
                                                                               file_presenter_class,
                                                                               current_ability)
  end

  def viewing_hint
    nil
  end

  def logical_order
    {}
  end

  def label
    []
  end

  private

    # TODO: Extract this to ActiveFedora::Aggregations::ListSource
    def ordered_ids
      ActiveFedora::SolrService.query("member_of_collection_ids_ssim:#{id}", fl: "id", rows: 10_000).map do |x|
        x["id"]
      end
    end

    def file_presenter_class
      MultiVolumeWorkShowPresenter::DynamicShowPresenter.new
    end
end
