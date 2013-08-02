$:.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))
$:.unshift(File.join(File.dirname(__FILE__), '..', 'spec'))

describe JobseekersByDateReportGenerator do
  before(:each) do
    jobfactory = JobFactory.new
    idnumberservice = IDNumberService.new

    @examplefactory = ExampleFactory.new

    submissionservice = SubmissionService.new

    job = @examplefactory.build_job

    recruiter = @examplefactory.build_recruiter

    @posting = Posting.new(job: job, posted_by: recruiter)

    @jobseeker1 = @examplefactory.build_jobseeker
    @jobseeker2 = @examplefactory.build_jobseeker
    @jobseeker3 = @examplefactory.build_jobseeker

    applicationlist = ApplicationList.new
    postinglist = PostingList.new
    
    jobposter = JobPoster.new(recruiter: recruiter, postinglist: postinglist)
    jobposter.post_job(job)

    applicationpreparer1 = ApplicationPreparer.new(jobseeker: @jobseeker1, applicationlist: applicationlist)
    applicationpreparer2 = ApplicationPreparer.new(jobseeker: @jobseeker2, applicationlist: applicationlist)
    applicationpreparer3 = ApplicationPreparer.new(jobseeker: @jobseeker3, applicationlist: applicationlist)

    submitter1 = Submitter.new(application: applicationpreparer1.prepare_application, submissionservice: submissionservice)
    submitter2 = Submitter.new(application: applicationpreparer2.prepare_application, submissionservice: submissionservice)
    submitter3 = Submitter.new(application: applicationpreparer3.prepare_application, submissionservice: submissionservice)

    @submissionrecordlist = SubmissionRecordList.new

    @submissionrecorder1 = SubmissionRecorder.new(submitter: submitter1, submissionrecordlist: @submissionrecordlist)
    @submissionrecorder2 = SubmissionRecorder.new(submitter: submitter2, submissionrecordlist: @submissionrecordlist)
    @submissionrecorder3 = SubmissionRecorder.new(submitter: submitter3, submissionrecordlist: @submissionrecordlist)
  end

  describe "Generate Jobseeker Report" do
    it "should list Jobseekers who applied on a given date" do
      checked_date = Date.new(2012, 12, 21)
      not_checked_date = Date.new(2010, 9, 5)

      @submissionrecorder1.submit_application(posting: @posting, date: checked_date)
      @submissionrecorder2.submit_application(posting: @posting, date: not_checked_date)
      @submissionrecorder3.submit_application(posting: @posting, date: checked_date)

      reportgenerator = JobseekersByDateReportGenerator.new(checked_date)

      report = reportgenerator.generate_from(@submissionrecordlist)

      report.to_string.should == "Alice Green\nCandice Yarn"
    end
  end
end

describe AggregateReportGenerator do
  before(:each) do
    jobfactory = JobFactory.new
    idnumberservice = IDNumberService.new

    @examplefactory = ExampleFactory.new

    submissionservice = SubmissionService.new

    @job1 = @examplefactory.build_job
    @job2 = @examplefactory.build_job
    @job3 = @examplefactory.build_job

    @recruiter1 = @examplefactory.build_recruiter
    @recruiter2 = @examplefactory.build_recruiter
    @recruiter3 = @examplefactory.build_recruiter

    posting1 = Posting.new(job: @job1, posted_by: @recruiter1)
    posting2 = Posting.new(job: @job2, posted_by: @recruiter2)
    posting3 = Posting.new(job: @job3, posted_by: @recruiter3)

    jobseeker1 = @examplefactory.build_jobseeker
    jobseeker2 = @examplefactory.build_jobseeker
    jobseeker3 = @examplefactory.build_jobseeker

    applicationlist = ApplicationList.new
    postinglist = PostingList.new
    
    jobposter1 = JobPoster.new(recruiter: @recruiter1, postinglist: postinglist)
    jobposter2 = JobPoster.new(recruiter: @recruiter2, postinglist: postinglist)
    jobposter3 = JobPoster.new(recruiter: @recruiter3, postinglist: postinglist)

    jobposter1.post_job(@job1)
    jobposter2.post_job(@job2)
    jobposter3.post_job(@job3)

    applicationpreparer1 = ApplicationPreparer.new(jobseeker: jobseeker1, applicationlist: applicationlist)
    applicationpreparer2 = ApplicationPreparer.new(jobseeker: jobseeker2, applicationlist: applicationlist)
    applicationpreparer3 = ApplicationPreparer.new(jobseeker: jobseeker3, applicationlist: applicationlist)

    submitter1 = Submitter.new(application: applicationpreparer1.prepare_application, submissionservice: submissionservice)
    submitter2 = Submitter.new(application: applicationpreparer2.prepare_application, submissionservice: submissionservice)
    submitter3 = Submitter.new(application: applicationpreparer3.prepare_application, submissionservice: submissionservice)

    @submissionrecordlist = SubmissionRecordList.new

    submissionrecorder1 = SubmissionRecorder.new(submitter: submitter1, submissionrecordlist: @submissionrecordlist)
    submissionrecorder2 = SubmissionRecorder.new(submitter: submitter2, submissionrecordlist: @submissionrecordlist)
    submissionrecorder3 = SubmissionRecorder.new(submitter: submitter3, submissionrecordlist: @submissionrecordlist)

    date = Date.new(2012, 12, 21)

    submissionrecorder1.submit_application(posting: posting1, date: date)
    submissionrecorder2.submit_application(posting: posting2, date: date)
    submissionrecorder3.submit_application(posting: posting3, date: date)

    @repost = Proc.new do
      submissionrecorder1.submit_application(posting: posting1, date: date)
    end
  end

  describe "Generate Job Aggregate Application Report" do
    it "should show the number of times that Jobseekers applied to only the given Job" do
      reportgenerator = JobAggregateReportGenerator.new(@job1)

      report = reportgenerator.generate_from(@submissionrecordlist)

      report.to_string.should == "Applied Technologist: 1"
    end

    it "should show the number of times that Jobseekers applied to only the given Job after multiple submissions" do
      @repost.call
      @repost.call
      
      reportgenerator = JobAggregateReportGenerator.new(@job1)

      report = reportgenerator.generate_from(@submissionrecordlist)

      report.to_string.should == "Applied Technologist: 3"
    end
  end

  describe "Generate Recruiter Aggregate Application Report" do
    it "should show the number of times that Jobseekers applied to Jobs posted by the given Recruiter" do
      reportgenerator = RecruiterAggregateReportGenerator.new(@recruiter1)

      report = reportgenerator.generate_from(@submissionrecordlist)

      report.to_string.should == "Rudy Allen: 1"
    end

    it "should show the number of times that Jobseekers applied to Jobs posted by the given Recruiter after multiple submissions" do
      @repost.call
      @repost.call
      
      reportgenerator = RecruiterAggregateReportGenerator.new(@recruiter1)

      report = reportgenerator.generate_from(@submissionrecordlist)

      report.to_string.should == "Rudy Allen: 3"
    end
  end

  describe "Generate Overall Application Report" do
    it "should show just the headers when given an empty SubmissionRecordList" do
      reportgenerator = ApplicationReportGenerator.new

      report = reportgenerator.generate_from(SubmissionRecordList.new)

      report.to_string.should == "| Jobseeker | Recruiter | Job Title | Date |"
    end

    it "should, for each SubmissionRecord, show the Jobseeker's name, Job title, Recruiter name, and submission Date" do
      reportgenerator = ApplicationReportGenerator.new

      report = reportgenerator.generate_from(@submissionrecordlist)

      report.to_string.should ==
        "| Jobseeker    | Recruiter       | Job Title            | Date       |\n" +
        "| Alice Green  | Rudy Allen      | Applied Technologist | 12/21/2012 |\n" +
        "| Betty Smith  | Rachel Breecher | Bench Warmer         | 12/21/2012 |\n" +
        "| Candice Yarn | Ralph Colbert   | Candy Tester         | 12/21/2012 |"
    end

    it "should generate a report in CSV format" do
      reportgenerator = ApplicationReportGenerator.new

      report = reportgenerator.generate_from(@submissionrecordlist)

      report.to_csv.should ==
        "Jobseeker,Recruiter,Job Title,Date\n" + 
        "Alice Green,Rudy Allen,Applied Technologist,12/21/2012\n" +
        "Betty Smith,Rachel Breecher,Bench Warmer,12/21/2012\n" +
        "Candice Yarn,Ralph Colbert,Candy Tester,12/21/2012\n"
    end

    it "should generate a report in HTML format" do
      reportgenerator = ApplicationReportGenerator.new

      report = reportgenerator.generate_from(@submissionrecordlist)

      report.to_html.should ==
        "<table>\n" +
        "<tr><th>Jobseeker</th><th>Recruiter</th><th>Job Title</th><th>Date</th></tr>\n" + 
        "<tr><td>Alice Green</td><td>Rudy Allen</td><td>Applied Technologist</td><td>12/21/2012</td></tr>\n" +
        "<tr><td>Betty Smith</td><td>Rachel Breecher</td><td>Bench Warmer</td><td>12/21/2012</td></tr>\n" +
        "<tr><td>Candice Yarn</td><td>Ralph Colbert</td><td>Candy Tester</td><td>12/21/2012</td></tr>\n" +
        "</table>"
    end
  end
end
