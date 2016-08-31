# Command that shows a list of goals
class Goal::GoalIndexCommand < Core::Command
  attr_accessor :id, :completed
  attr_accessor :person_repository

  validates :id,        presence: true,
                        'Core::Validator::Exists' => ->(x) { x.person_repository.find_not_deleted(x.id) }
  validates :id, 'Core::Validator::Owner' => ->(x) { x.person_repository.find(x.id) }
  validates :completed, inclusion: [true, false, nil, 'false', 'true']

  # Sets all variables
  # @param [Object] params
  # @see Family:Child
  # @see Goal::GoalRepository
  # @see Goal::GoalService
  # @see Family::PersonRepository
  # @see Family::PersonPresenter
  def initialize(params)
    super(params)
    @child_model = Family::Child
    @goal_repository = Goal::GoalRepository.get
    @goal_service = Goal::GoalService.get
    @person_repository = Family::PersonRepository.get(@child_model)
    @person_presenter = Family::PersonPresenter.get
  end

  # Runs command
  # @return [Hash]
  def execute
    child = @person_repository.find(id)
    is_completed = completed.nil? ? nil : completed == 'true'
    goals = @person_presenter.child_goals_to_hash(child, is_completed)
    { goals: goals }
  end
end