$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'spec'))

require 'jobs'
require 'jobseekers'
require 'employers'
require 'resumes'
require 'submissions'

describe "Jobseekers can apply to jobs posted by employers" do
  it "There are 2 different kinds of Jobs posted by employers: JReq and ATS." do
  end

  before(:each) do
    @jobseeker = Jobseeker.new
    @other_jobseeker = Jobseeker.new
    @employer = Employer.new(name: "Robert Recruit")
    @employer.take_on_role(JobPoster)

    unposted_ats_job = UnpostedJob.new(title: "Example ATS Job", type: JobType.ATS)
    unposted_jreq_job = UnpostedJob.new(title: "Example JReq Job", type: JobType.JReq)

    @ats_job = @employer.post_job(unposted_ats_job)
    @jreq_job = @employer.post_job(unposted_jreq_job)

    @resume = @jobseeker.draft_resume
  end

  describe "ATS jobs do not require a resume to apply to them" do
    describe Jobseeker do
      it "should be able to apply to ATS jobs without a resume" do
        submission = @jobseeker.apply_to(job: @ats_job, with_resume: NoResume)

        submission.valid?.should be_true
      end

      it "should not be able to apply to ATS jobs with a resume (missing from original spec)" do
        submission = @jobseeker.apply_to(job: @ats_job, with_resume: @resume)

        submission.valid?.should be_false
      end
    end
  end

  describe "JReq jobs require a resume to apply to them" do
    describe Jobseeker do
      it "should be able to apply to JReq jobs with a resume" do
        submission = @jobseeker.apply_to(job: @jreq_job, with_resume: @resume)

        submission.valid?.should be_true
      end

      it "should not be able to apply to JReq jobs without a resume" do
        submission = @jobseeker.apply_to(job: @jreq_job, with_resume: NoResume)

        submission.valid?.should be_false
      end
    end
  end

  describe "Jobseekers should be able to apply to different jobs with different resumes" do
    before(:each) do
      unposted_jreq_job2 = UnpostedJob.new(title: "Example JReq Job 2", type: JobType.JReq)

      @jreq_job2 = @employer.post_job(unposted_jreq_job2)

      @resume2 = @jobseeker.draft_resume
    end

    describe Jobseeker do
      it "should be able to apply to different jobs with different resume" do
        submission1 = @jobseeker.apply_to(job: @jreq_job, with_resume: @resume)
        submission2 = @jobseeker.apply_to(job: @jreq_job2, with_resume: @resume2)

        submission1.valid?.should be_true
        submission2.valid?.should be_true
      end
    end
  end

  describe "Jobseekers can not apply to a job with someone else’s resume" do
    before(:each) do
      @others_resume = @other_jobseeker.draft_resume
    end

    describe Jobseeker do
      it "cannot apply to a job with another jobseeker's resume" do
        submission = @jobseeker.apply_to(job: @jreq_job, with_resume: @others_resume)

        submission.valid?.should be_false
      end
    end
  end
end