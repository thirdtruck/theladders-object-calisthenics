$:.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'spec'))

require 'labels'
require 'jobs'
require 'jobseekers'
require 'recruiters'
require 'postings'
require 'resumes'
require 'examples'
require 'compositors'

describe "Compositors" do
  before(:each) do
    @examplefactory = ExampleFactory.new

    @jobseeker = @examplefactory.build_jobseeker
    @recruiter = @examplefactory.build_recruiter

    @job = @examplefactory.build_job

    @jobapplicationlist = JobApplicationList.new
    @postinglist = PostingList.new

    @jobapplicationsubmissionservice = JobApplicationSubmissionService.new
  end

  describe JobPoster do
    describe "#post_job" do
      it "should return a Posting" do
        jobposter = JobPoster.new(recruiter: @recruiter, postinglist: @postinglist)

        posting = jobposter.post_job(@job)

        [posting.class, *posting.class.ancestors].should include(Posting)
      end
    end
  end

  describe JobApplicationPreparer do
    describe "#prepare_application" do
      it "should return a JobApplication" do
        jobapplicationpreparer = JobApplicationPreparer.new(jobseeker: @jobseeker, jobapplicationlist: @jobapplicationlist)

        jobapplication = jobapplicationpreparer.prepare_application

        [jobapplication.class, *jobapplication.class.ancestors].should include(JobApplication)
      end
    end
  end

  describe JobApplicationSubmitter do
    before(:each) do
      jobapplicationpreparer = JobApplicationPreparer.new(jobseeker: @jobseeker, jobapplicationlist: @jobapplicationlist)

      @jobapplication = jobapplicationpreparer.prepare_application

      jobposter = JobPoster.new(recruiter: @recruiter, postinglist: @postinglist)

      @posting = jobposter.post_job(@job)
    end

    describe "#submit_application" do
      it "should return a JobApplicationSubmission" do
        jobapplicationsubmitter = JobApplicationSubmitter.new(jobapplication: @jobapplication, jobapplicationsubmissionservice: @jobapplicationsubmissionservice)


        jobapplicationsubmission = jobapplicationsubmitter.submit_application(@posting)

        [jobapplicationsubmission.class, *jobapplicationsubmission.class.ancestors].should include(JobApplicationSubmission)
      end
    end
  end
end
