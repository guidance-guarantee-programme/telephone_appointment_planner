class GuiderImporter
  def initialize(name)
    @name = name
  end

  def call
    User.find_by!(uid: mappings[name])
  end

  private

  def mappings # rubocop:disable Metrics/MethodLength
    {
      'Adrian Nunn'           => '15ec18d0-7355-0134-fe9d-5eea3e482a8b',
      'Alan Wenborn'          => '16aa2f10-7355-0134-fe9d-5eea3e482a8b',
      'Alistair Elliott'      => '16cf73a0-7355-0134-fe9d-5eea3e482a8b',
      'Andrew Creeden'        => '16ebdca0-7355-0134-fe9d-5eea3e482a8b',
      'Anne Mahon'            => '17080bb0-7355-0134-fe9d-5eea3e482a8b',
      'Carlos Simoes'         => '1748c9b0-7355-0134-fe9d-5eea3e482a8b',
      'Catherine McCunn'      => '1766eac0-7355-0134-fe9d-5eea3e482a8b',
      'Charlotte Jackson'     => '17858cf0-7355-0134-fe9d-5eea3e482a8b',
      'Christopher Wrightson' => '17a1c480-7355-0134-fe9d-5eea3e482a8b',
      'Cilla Christmas'       => '17c1f280-7355-0134-fe9d-5eea3e482a8b',
      'Colin Hasell'          => '17d53290-7355-0134-fe9d-5eea3e482a8b',
      'Colin Scamell'         => '17ecdf80-7355-0134-fe9d-5eea3e482a8b',
      'Craig Rimmer'          => '1827aed0-7355-0134-fe9d-5eea3e482a8b',
      'Daniel Tinmouth'       => '18653000-7355-0134-fe9d-5eea3e482a8b',
      'David Loosemore'       => '18ab6000-7355-0134-fe9d-5eea3e482a8b',
      'Ernie Sharp'           => '18f581c0-7355-0134-fe9d-5eea3e482a8b',
      'Francis Phillips'      => '1924d9b0-7355-0134-fe9d-5eea3e482a8b',
      'George Emsden'         => '19496ce0-7355-0134-fe9d-5eea3e482a8b',
      'Jim Nokku'             => '196628e0-7355-0134-fe9d-5eea3e482a8b',
      'John Fitzgerald'       => '1985ebf0-7355-0134-fe9d-5eea3e482a8b',
      'John Hussey'           => '19ab2790-7355-0134-fe9d-5eea3e482a8b',
      'John Shearer'          => '19cf4c50-7355-0134-fe9d-5eea3e482a8b',
      'Julian Abel'           => '1a05b5c0-7355-0134-fe9d-5eea3e482a8b',
      'Julie Stewart'         => '1a296f70-7355-0134-fe9d-5eea3e482a8b',
      'Kevin Burge'           => '1a440190-7355-0134-fe9d-5eea3e482a8b',
      'Lee Benham'            => '1a5efa60-7355-0134-fe9d-5eea3e482a8b',
      'Lori Usher'            => '1a848a00-7355-0134-fe9d-5eea3e482a8b',
      'Lynette Conway'        => '1aa129a0-7355-0134-fe9d-5eea3e482a8b',
      'Martin Bell'           => '1abc9140-7355-0134-fe9d-5eea3e482a8b',
      'Martyn Blackman'       => '1ae5d6c0-7355-0134-fe9d-5eea3e482a8b',
      'Melinda Riley'         => '1b05ecb0-7355-0134-fe9d-5eea3e482a8b',
      'Michelle Cracknell'    => '1b2cf510-7355-0134-fe9d-5eea3e482a8b',
      'Nick Mines'            => '1b5aac10-7355-0134-fe9d-5eea3e482a8b',
      'Nicola Collinson'      => '1b89caf0-7355-0134-fe9d-5eea3e482a8b',
      'Nigel Kern'            => '1bb3d320-7355-0134-fe9d-5eea3e482a8b',
      'Pam Atherton'          => '1bdc6d60-7355-0134-fe9d-5eea3e482a8b',
      'Philippa Aaronson'     => '1bfe3e00-7355-0134-fe9d-5eea3e482a8b',
      'Rachel Ward'           => '1c17cf00-7355-0134-fe9d-5eea3e482a8b',
      'Raj Kakkad'            => '1c3540e0-7355-0134-fe9d-5eea3e482a8b',
      'Richard Church'        => '1c512f30-7355-0134-fe9d-5eea3e482a8b',
      'Robert Dunmore'        => '1c6dcd10-7355-0134-fe9d-5eea3e482a8b',
      'Roy Barrett'           => '1c9601f0-7355-0134-fe9d-5eea3e482a8b',
      'Sally Asare'           => '1cb792e0-7355-0134-fe9d-5eea3e482a8b',
      'Shaun Pont'            => '1ce03c80-7355-0134-fe9d-5eea3e482a8b',
      'Tony Bird'             => '1d16abc0-7355-0134-fe9d-5eea3e482a8b',
      'Trisha Higgins'        => '1d4613b0-7355-0134-fe9d-5eea3e482a8b',
      'Waheeda Noormohamed'   => '1d616b80-7355-0134-fe9d-5eea3e482a8b'
    }
  end

  attr_reader :name
end
