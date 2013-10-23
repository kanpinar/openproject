#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2013 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

class ChiliProject::PrincipalAllowanceEvaluator::Default < ChiliProject::PrincipalAllowanceEvaluator::Base
  def allowed_in_project_scope(action, project)
    roles = Role.arel_table
    members = Member.arel_table

    User.includes(:members => :roles)
        .where(roles['permissions'].matches("%#{action}%"))
        .where(members['project_id'].eq(project.id))
  end

  def allowed_user_agnostic_scope(action)
    users = User.arel_table
    roles = Role.arel_table

    fallback_role = if @user.anonymous?
                      Role.anonymous
                    else
                      Role.non_member
                    end

    agnostic_scope = users.join(roles)
                          .on(roles[:id].eq(fallback_role.id).and(roles[:permissions].matches("%#{action}%"))).join_sources

    User.joins(agnostic_scope)
  end

  def allowed_globally_scope(action)
    roles = Role.arel_table

    User.includes(:members => :roles)
        .where(roles['permissions'].matches("%#{action}%"))
  end
end
