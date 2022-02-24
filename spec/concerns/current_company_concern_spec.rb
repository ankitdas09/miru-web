# frozen_string_literal: true

require "rails_helper"

RSpec.describe CurrentCompanyConcern do
  let (:company) { create(:company) }
  let (:user) { create(:user, current_workspace_id: company.id) }
  let (:user_2) { create(:user) }

  before do
    create(:company_user, company_id: company.id, user_id: user.id)
    user.add_role :admin, company

    @stub_class = Class.new do
      include ActionController::Helpers
      include CurrentCompanyConcern
      attr_accessor :current_user

      def initialize(current_user)
        @current_user = current_user
      end
    end
  end

  describe "When current user has current workspace id" do
    it "returns company record based on company id stored in current_workspace_id column" do
      expect(@stub_class.new(user).current_company).to eq(company)
    end
  end

  describe "When current user doesn't have current workspace id" do
    before do
      user.update(current_workspace_id: nil)
    end

    it "returns user's first company" do
      expect(@stub_class.new(user).current_company).to eq(user.companies.first)
    end
  end

  describe "When current user doesn't have current workspace id and not associated with any company" do
    before do
      user.update(current_workspace_id: nil)
      user.company_users.destroy
    end

    it "returns nil" do
      expect(@stub_class.new(user_2).current_company).to be_nil
    end
  end

  describe "When current user is nil" do
    before do
      user.update(current_workspace_id: nil)
      user.company_users.destroy
    end

    it "returns nil" do
      expect(@stub_class.new(nil).current_company).to be_nil
    end
  end
end
