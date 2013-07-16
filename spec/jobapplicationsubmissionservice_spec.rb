$:.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'spec'))

require 'labels'
require 'jobs'
require 'examples'

describe JobApplicationSubmissionService do
  before(:each) do

    examplefactory = ExampleFactory.new
    
    jobseeker = examplefactory.build_jobseeker
    recruiter = examplefactory.build_recruiter
    job = examplefactory.build_job

    @posting = Posting.new(job: job, posted_by: recruiter)
    @jobapplication = JobApplication.new(jobseeker: jobseeker)

    @jobapplicationsubmissionservice = JobApplicationSubmissionService.new
  end

  # TODO: Ask whether this implicit return is a bad idea and, if so, for alternative approaches.
  describe "#apply_jobapplication_to_posting" do
    it "should return the JobApplicationSubmission created to record the posting activity" do
      jobapplicationsubmission = @jobapplicationsubmissionservice.apply_jobapplication_to_posting(jobapplication: @jobapplication, posting: @posting)
      jobapplicationsubmission.submitted_for_jobapplication?(@jobapplication).should be_true
      jobapplicationsubmission.submitted_for_posting?(@posting).should be_true
    end
  end
end

