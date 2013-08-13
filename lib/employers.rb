require 'utilities'
require 'jobs'

class Employer
  include Reports
  include RoleTaker
  
  def initialize(name: nil)
    @name = name
  end

  when_reporting :employer_name do |reportable|
    @name.report_name_to(reportable)
  end
end

class AppliedToEmployersJobsJobApplierList < JobseekerList
  def self.filtered_from(jobapplierlist: nil, employer: nil)
    filtered_list = jobapplierlist.select do |jobapplier|
      jobapplier.applied_to_jobs_posted_by?(employer)
    end
    AppliedToEmployersJobsJobApplierList.new(filtered_list)
  end
end
