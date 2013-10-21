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

require 'spec_helper'

describe User do
  let(:user) { FactoryGirl.build(:user) }
  let(:anonymous) { FactoryGirl.build(:anonymous) }
  let(:project) { FactoryGirl.build(:project) }
  let(:role) { FactoryGirl.build(:role) }
  let(:anonymous_role) { FactoryGirl.build(:anonymous_role) }
  let(:member) { FactoryGirl.build(:member, :project => project,
                                        :roles => [role],
                                        :principal => user) }


  describe "allowed_to?" do
    describe "w/ the user being a member in the project
              w/o the role having the necessary permission" do

      before do
        member.save!
      end

      it "should be false" do
        user.allowed_to?(:add_work_packages, project).should be_false
      end
    end

    describe "w/ the user being a member in the project
              w/ the role having the necessary permission" do
      before do
        role.permissions << :add_work_packages

        member.save!
      end

      it "should be true" do
        user.allowed_to?(:add_work_packages, project).should be_true
      end
    end

    describe "w/o the user being a member in the project
              w/ non member being allowed the action
              w/ the project being private" do
      before do
        project.is_public = false
        project.save!

        non_member = Role.non_member

        non_member.permissions << :add_work_packages
        non_member.save!
      end

      it "should be false" do
        user.allowed_to?(:add_work_packages, project).should be_false
      end
    end

    describe "w/o the user being a member in the project
              w/ the project being public
              w/ non members being allowed the action" do

      before do
        project.is_public = true
        project.save!

        non_member = Role.non_member

        non_member.permissions << :add_work_packages
        non_member.save!
      end

      it "should be false" do
        user.allowed_to?(:add_work_packages, project).should be_true
      end
    end

    describe "w/o the user being anonymous
              w/ the project being public
              w/ anonymous being allowed the action" do

      before do
        project.is_public = true
        project.save!

        anonymous_role.permissions << :add_work_packages
        anonymous_role.save!
      end

      it "should be false" do
        anonymous.allowed_to?(:add_work_packages, project).should be_true
      end
    end
  end
end
