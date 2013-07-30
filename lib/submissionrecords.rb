class SubmissionRecord
  def initialize(submission: nil, recorded_at_datetime: nil)
    @submission = submission
    @recorded_at_datetime = recorded_at_datetime
  end

  def recorded_at_datetime?(datetime)
    @recorded_at_datetime == datetime
  end

  def add_jobseeker_to_jobseekerlist(jobseekerlist)
    @submission.add_jobseeker_to_jobseekerlist(jobseekerlist)
  end

  def add_posting_to_postinglist(postinglist)
    @submission.add_posting_to_postinglist(postinglist)
  end

  def applied_to_by_jobseeker?(jobseeker)
    @submission.application_applied_to_by?(jobseeker)
  end

  def posting_posted_by_recruiter?(recruiter)
    @submission.posting_posted_by_recruiter?(recruiter)
  end
end

class SubmissionRecordList < List
  def submissionrecords_for_postings_by_recruiter(recruiter)
  end

  def jobseekers_applying_to_jobs_posted_by_recruiter(recruiter)
    jobseekerlist = JobseekerList.new

    filtered_submissionrecordlist = select do |submissionrecord|
      submissionrecord.posting_posted_by_recruiter?(recruiter)
    end

    filtered_submissionrecordlist.each do |submissionrecord|
      submissionrecord.add_jobseeker_to_jobseekerlist(jobseekerlist)
    end

    jobseekerlist
  end

  def postings_posted_by_recruiter(recruiter)
    postinglist = PostingList.new

    filteredrecords = select do |submissionrecord|
      submissionrecord.posting_posted_by_recruiter?(recruiter)
    end

    filteredrecords.each do |record|
      record.add_posting_to_postinglist(postinglist)
    end

    postinglist
  end

  def jobs_posted_by(recruiter)
    joblist = JobList.new

    filtered_postinglist = postings_posted_by_recruiter(recruiter) # Why do I keep running into empty lists or what looks like them?
    filtered_postinglist.each do |posting|
      posting.add_job_to_joblist(joblist)
    end

    joblist
  end
end

class RecruiterSubmissionRecordFilter
end