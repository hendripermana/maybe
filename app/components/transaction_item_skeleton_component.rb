class TransactionItemSkeletonComponent < ViewComponent::Base
  attr_reader :view_ctx

  def initialize(view_ctx: "global")
    @view_ctx = view_ctx
  end

  def container_classes
    "grid grid-cols-12 items-center p-4 lg:p-4 rounded-lg bg-container"
  end

  def name_column_classes
    view_ctx == "global" ? "lg:col-span-8" : "lg:col-span-6"
  end
end