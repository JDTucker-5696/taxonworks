require 'rails_helper'

describe 'PublicContents', type: :feature do
  context 'resource routes' do
    #  before { 
    #    sign_in_user_and_select_project
    #  }

    # The scenario for creating PublicContents has not been developed. 
    # It must handle these three calls for logged in/not logged in users.
    # It may be that these features are ultimately tested in a task.
    describe 'POST /create' do
    end

    describe 'PATCH /update' do
    end

    describe 'DELETE /destroy' do
    end
  end

  # skip 'difference b/w user and worker (latter can not generate these data)'
end
