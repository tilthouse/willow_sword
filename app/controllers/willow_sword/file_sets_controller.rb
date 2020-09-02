require_dependency "willow_sword/application_controller"

module WillowSword
  class FileSetsController < ApplicationController
    before_action :set_file_set_klass
    attr_reader :file_set, :object

    include WillowSword::ProcessRequest
    include WillowSword::WorksBehavior
    include WillowSword::FileSetsBehavior
    include ::Integrator::Hyrax::FileSetsBehavior
  end
end
