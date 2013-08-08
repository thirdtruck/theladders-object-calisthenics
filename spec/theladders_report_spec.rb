$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'spec'))

$:.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib', 'reports'))

Dir[File.join(File.dirname(__FILE__), '..', 'lib', 'reports', '*.rb')].each do |report_lib|
  require report_lib
end

require 'jobs'
require 'jobseekers'
require 'employers'
require 'resumes'
require 'submissions'

describe "Jobseekers should be able to see a listing of the jobs for which they have applied" do
  before(:each) do
    @jobseeker = Jobseeker.new
    @other_jobseeker = Jobseeker.new

    @employer = Employer.new(name: "Robert Recruit")
    @employer.take_on_role(JobPoster)

    unposted_job1 = UnpostedJob.new(title: "Valid Job 1", type: JobType.ATS)
    unposted_job2 = UnpostedJob.new(title: "Valid Job 2", type: JobType.ATS)

    @posted_job1 = @employer.post_job(unposted_job1)
    @posted_job2 = @employer.post_job(unposted_job2)

    other_job = UnpostedJob.new(title: "Invalid Job", type: JobType.ATS)

    @other_posted_job = @employer.post_job(other_job)

    @jobseeker.apply_to(job: @posted_job1, with_resume: NoResume)
    @jobseeker.apply_to(job: @posted_job2, with_resume: NoResume)

    @other_jobseeker.apply_to(job: @other_posted_job, with_resume: NoResume)

    @jobseekerlist = JobseekerList.new([@jobseeker, @other_jobseeker]) 
  end

  describe JobseekerApplicationsReport do
    it "should list the jobs to which a given jobseeker has applied" do
      reportgenerator = JobseekerApplicationsReportGenerator.new(@jobseeker)

      report = reportgenerator.generate_from(@jobseekerlist)

      report.to_string.should == "Job[Title: Valid Job 1][Employer: Robert Recruit]\nJob[Title: Valid Job 2][Employer: Robert Recruit]"
    end

    it "should only list the jobs to which a given jobseeker has applied" do
      reportgenerator = JobseekerApplicationsReportGenerator.new(@jobseeker)

      report = reportgenerator.generate_from(@jobseekerlist)

      report.to_string.should == "Job[Title: Valid Job 1][Employer: Robert Recruit]\nJob[Title: Valid Job 2][Employer: Robert Recruit]"
    end
  end
end

describe "Jobs, when displayed, should be displayed with a title and the name of the employer who posted it" do
  describe JobReport do
    before(:each) do
      employer = Employer.new(name: "Robert Recruit")
      employer.take_on_role(JobPoster)

      job = UnpostedJob.new(title: "Example Job", type: JobType.ATS)

      posted_job = employer.post_job(job)

      @report = JobReport.new(posted_job)
    end

    it "should list the job title and the name of the employer that posted it" do
      @report.to_string.should == "Job[Title: Example Job][Employer: Robert Recruit]"
    end

    it "should list the job title and the name of the employer that posted it" do
      @report.to_string.should == "Job[Title: Example Job][Employer: Robert Recruit]"
    end
  end
end

describe "Jobseekers should be able to see a listing of jobs they have saved for later viewing" do
  before(:each) do
    @jobseeker = Jobseeker.new
    @jobseeker = JobSaver.with_role_performed_by(@jobseeker)

    employer = Employer.new(name: "Erin Employ")
    employer.take_on_role(JobPoster)

    unposted_job = UnpostedJob.new(title: "A Job", type: JobType.ATS)

    @job = employer.post_job(unposted_job)

    @jobseeker.save_job(@job)
  end

  describe SavedJobListReport do
    it "should list the jobs saved by a jobseeker" do
      jobseekers = JobseekerList.new([@jobseeker])
      report = SavedJobListReport.new(jobseekers)
      report.to_string.should == "Job[Title: A Job][Employer: Erin Employ]"
    end
  end
end
