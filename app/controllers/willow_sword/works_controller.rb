require_dependency "willow_sword/application_controller"

module WillowSword
  class WorksController < ApplicationController
    before_action :set_work_klass
    attr_reader :object, :current_user

    include WillowSword::ProcessRequest
    include WillowSword::WorksBehavior
    include ::Integrator::Hyrax::WorksBehavior
  end
end
