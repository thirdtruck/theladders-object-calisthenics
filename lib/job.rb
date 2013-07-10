class Job
  def initialize(title: title, jobtype: jobtype, posted_by: posted_by)
    @title = title
    @jobtype = jobtype
    @posted_by = posted_by
  end

  def posted_by(recruiter)
    @posted_by == recruiter
  end

  def requires_resume?
    @jobtype.requires_resume?
  end
end

class SavedJobRecord
  def initialize(job: nil, jobseeker: nil)
    @job = job
    @jobseeker = jobseeker
  end

  def saved_by?(jobseeker)
    @jobseeker == jobseeker
  end

  def add_job_to_joblist(joblist)
    joblist.add(@job)
  end
end

class JobList
  def initialize(jobs=[])
    @jobs = jobs
  end

  def add(job)
    @jobs.push job
  end

  def post(job)
    add(job)
  end
  
  def include?(job)
    @jobs.include?(job)
  end

  def posted_by(recruiter)
    filtered_jobs = @jobs.select do |job|
      job.posted_by(recruiter)
    end

    JobList.new(filtered_jobs)
  end
end

class SavedJobRecordList
  def initialize(savedjobrecords=[])
    @savedjobrecords = savedjobrecords
  end

  def save_job_for_jobseeker(job: nil, jobseeker: nil)
    savedjobrecord = SavedJobRecord.new(job: job, jobseeker: jobseeker)
    @savedjobrecords.push(savedjobrecord)
  end

  def saved_by(jobseeker)
    filtered_savedjobrecords = @savedjobrecords.select do |savedjobrecord|
      savedjobrecord.saved_by?(jobseeker)
    end

    SavedJobRecordList.new(filtered_savedjobrecords)
  end

  def jobs_saved_by(jobseeker)
    joblist = JobList.new
    filtered_savedjobrecords = @savedjobrecords.select do |savedjobrecord|
      savedjobrecord.saved_by?(jobseeker)
    end

    filtered_savedjobrecords.each do |savedjobrecord|
      savedjobrecord.add_job_to_joblist(joblist)
    end

    joblist
  end
end
