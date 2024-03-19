class ShorturlController < ApplicationController
	  
  def index
    exhibit_id = exhibit_mapping[params[:short_id]]
    redirect_to "/spotlight/#{exhibit_id}"
  end
  
  private
    
    def exhibit_mapping
      {'cowan' => 'ian-mctaggart-cowan',
       'wwi' => 'wwi',
       'paris' => 'from-paris-to-victoria',
       'holiff' => 'holiff',
       'anarchy' => 'anarchy',
       'transarc' => 'transarc',
       'chinesenewspapers' => 'chinese-newspapers',
       'pre1900' => 'pre1900',
       'bctextbooks' => 'bc-textbooks',
       'iaff' => 'iaff',
       'galapagos' => 'galapagos'}
    end
end