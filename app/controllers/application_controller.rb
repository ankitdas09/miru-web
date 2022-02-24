# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include PunditHelper
  include ErrorHandler
  include CurrentCompanyConcern

  before_action :authenticate_user!, :validate_company!

  private
    def validate_company!
      return if current_user.nil?

      authorize current_company, :company_present?, policy_class: CompanyPolicy
    end
end
