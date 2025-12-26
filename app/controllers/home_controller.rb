# frozen_string_literal: true

class HomeController < ApplicationController
  def index
    @featured_workflows = Workflow.active.ordered.limit(3)
    @popular_forms = FormDefinition.active
      .where(code: %w[SC-100 SC-120 SC-104 SC-130])
      .ordered
    @categories = Category.active.where.not(parent_id: nil).ordered
  end

  def about
  end

  def help
  end
end
