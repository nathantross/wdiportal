class ProjectsController < ApplicationController

	def index
		current_user.visits.create(action: "view projects")
		@projects = Project.all
	end

	def new
		if current_user.role == "student"
			@project = Project.new
		else
			flash[:alert] = "You must be a student to add a project"
			current_user.visits.create(action: "UNAUTHORIZED attempt to create project")
			redirect_to projects_path
		end
	end

	def create
		if current_user.role == "student"
			parameters = params.require(:project).permit(:title, :url, :technology, :description)
			project = current_user.projects.create(parameters)
			current_user.visits.create(action: "create project")
			flash[:alert] = "Error: " + project.errors.full_messages.first if project.errors.any?
			redirect_to projects_path
		else
			flash[:alert] = "You must be a student to add a project"
			redirect_to projects_path
		end
	end

	def edit
		if current_user.role == "student"
			id = params.require(:id)
			@project = Project.find(id)
			if !@project.users.include? (current_user)
				flash[:alert] = "This is not your project!"
				current_user.visits.create(action: "UNAUTHORIZED attempt to edit project")
				redirect_to :projects
			end
		else
			flash[:alert] = "You must be a student"
			current_user.visits.create(action: "UNAUTHORIZED attempt to edit project")
			redirect_to projects_path
		end
	end

	def update
		if current_user.role == "student"
			id = params.require(:id)
			updates = params.require(:project).permit(:title, :url, :technology, :description)
			project = Project.find(id)
			if !project.users.include? (current_user)
				flash[:alert] = "This is not your project!"
				redirect_to :projects
			end
			project.update(updates)
			current_user.visits.create(action: "edit project")
			flash[:alert] = "Error: " + project.errors.full_messages.first if project.errors.any?
			redirect_to projects_path
		else
			flash[:alert] = "You must be a student"
			redirect_to projects_path
		end
	end

	def destroy
		if current_user.role == "student"
			id = params[:id]
			project = Project.find_by_id(id)
			if !project.users.include? (current_user)
				flash[:alert] = "This is not your project!"
				redirect_to :projects
			end
			project.destroy
			redirect_to projects_path
		else
			flash[:alert] = "You must be a student"
			redirect_to projects_path
		end
	end

	def join
		if current_user.role == "student"
			id = params.require(:id)
			project = Project.find(id)
			if project.users.include?(current_user)
				flash[:notice] = "You're already working on #{project.title}!"
			else
				project.users << current_user
				current_user.visits.create(action: "join project")
				flash[:notice] = "Good luck working on #{project.title}!"
			end
			redirect_to projects_path
		else
			flash[:alert] = "You must be a student to join a project"
			current_user.visits.create(action: "UNAUTHORIZED attempt to join project")
			redirect_to projects_path
		end
	end

	def leave
		if current_user.role == "student"
			id = params.require(:id)
			project = Project.find(id)
			if ( project.users.include?(current_user) ) && ( project.users.count != 1 )
				project.users.delete(current_user)
				current_user.visits.create(action: "leave project")
				flash[:notice] = "You are no longer working on #{project.title}"
			elsif project.users.include?(current_user)
				flash[:alert] = "You are the only student for this project, and cannot leave it. Select EDIT to delete the project."
			else
				flash[:notice] = "You weren't working on #{project.title}"
			end
			redirect_to projects_path
		else
			flash[:alert] = "You must be a student"
			current_user.visits.create(action: "UNAUTHORIZED attempt to leave project")
			redirect_to projects_path
		end
	end

end
