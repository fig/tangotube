namespace :db do
  task seed_leaders: :environment do
    [
        "Adam Cornett",
        "Adrian Costa",
        "Adrian Ferreyra",
        "Adrian Luppi",
        "Alejandro Hermida",
        "Alessandro Cavallaro",
        "Alexander Sergeev",
        "Alonso Alvarez",
        "Alper Ergökmen ",
        "Andrea Vighi",
        "Andres Molina",
        "Andres Sautel",
        "Angel Fabian Coria",
        "Anton Popichenko",
        "Ariel Almiron",
        "Ariel Ardit",
        "Ariel Taritolay",
        "Armin Marschall",
        "Artem Luchin",
        "Arttu Artkoski",
        "Bahar Güngör",
        "Braulio Martos",
        "Brenno Marques",
        "Bruno Ciarfella",
        "Bruno Tombari",
        "Bulent Karabagli",
        "Burak Özçelik",
        "Caio Rodriguez",
        "Carlitos Espinoza ",
        "Carlo Semaan",
        "Carlos Rodriguez",
        "Carlos Santos David",
        "Carlos Urrego",
        "Chiche Núñez",
        "Chicho Frumboli",
        "Chris Bakopoulos",
        "Christian Marquez",
        "Christiane Rohn",
        "Ciccio Aiello",
        "Constantin Rüger",
        "Constantinos Bagropoulos",
        "Cristian Miño",
        "Csongor Kicsi",
        "Daniel Arroyo",
        "Daniel Nacucchio",
        "Danilo Maddalena",
        "Dario Da Silva",
        "Demetrio Scafaria",
        "Diego Benavidez",
        "Diego Riemer",
        "Dimitris Biskas",
        "Diogo de Carvalho",
        "Dionisis Theodoropoulos",
        "Dmitriy Kuznetsov",
        "Dmitry Balaev",
        "Dmitry Vasin",
        "Dominic Bridge",
        "Eduardo Arquimbau",
        "Edwin Espinosa",
        "Emiliano Alcaraz",
        "Emilio Cornejo",
        "Erdi Arslan",
        "Eric Lindgren",
        "Ermis Karaboulas",
        "Espírito Nativo",
        "Esref Tekinalp",
        "Ezequiel Lopez",
        "Ezequiel Mendoza",
        "Fabian Peralta",
        "Facundo Pinero",
        "Facundo de la Cruz",
        "Fausto Carpino",
        "Federico Naveira",
        "Felix Naschke",
        "Fernando Carrasco",
        "Fernando Galera",
        "Fernando Gracia",
        "Fernando Rodríguez",
        "Fernando Sanchez",
        "Filippo Avignonesi",
        "Francesco Cieschi",
        "Gabor Novak",
        "Gabriel Marino",
        "Gaspar Godoy",
        "Gaston Camejo",
        "Gaston Torelli",
        "Germán Ballejo",
        "Giannis “El Gato”",
        "Gianpiero Galdi ",
        "Giorgos Nikou",
        "Giovanni Cocomero",
        "Giuseppe Vento",
        "Guille Barrionuevo",
        "Gustavo Colmenarejo",
        "Gustavo Gómez",
        "Gürkan Doğan",
        "Haris Mihail",
        "Horacio Godoy",
        "Horia Călin Pop",
        "Hugo Patyn",
        "Hüseyin Özmen",
        "Ilias Anastasiou",
        "Ioannis Karadimos",
        "Iossif Hassan",
        "Iris Basak Dogdu",
        "Ismael Ludman ",
        "Ivan Terrazas",
        "Ivo Ambrosi",
        "Jakub Grzybek",
        "Javier Antar",
        "Javier Rodriguez",
        "Joachim Dietiker",
        "Joe Corbata",
        "John Erban",
        "Jonathan Saavedra",
        "Jorge Firpo",
        "Jorge Lopez",
        "Jorge Torres",
        "Joscha Engel",
        "Jose Luis",
        "José Luis González",
        "Juan David Bedoya",
        "Juan David Vargas",
        "Juan Dietrich Lange",
        "Juan Malizia",
        "Juan Martin",
        "Juan Martin Carrara",
        "Juan Pablo Ramirez",
        "Julian Vilardo",
        "Julio Alvarez",
        "Julio Balmaceda",
        "Julio Cesar Calderon",
        "Kyriakos Michas",
        "Leandro Furlan",
        "Leandro Palou",
        "Leonardo Barrionuevo",
        "Leonardo Sardella",
        "Leonel Mendieta",
        "Levan Gomelauri",
        "Loukas Balokas",
        "Lucas Carrizo",
        "Lucas Galera",
        "Lucas Molina Gazcon",
        "Lucian Stan",
        "Luis Squicciarini",
        "Lukasz Wisniewski",
        "Majo Martirena",
        "Malachai Payne",
        "Marcelo Gutierrez",
        "Marek Matysiak",
        "Mariano Otero",
        "Mario De Camillis",
        "Marko Miljevic",
        "Martin Birnbaumer",
        "Martin Cardoso",
        "Martin Lutsch",
        "Martin Maldonado",
        "Martin Ojeda",
        "Matias Facio",
        "Matteo Antonietti",
        "Matteo Panero",
        "Maude Andrey",
        "Maurizio Ghella",
        "Max van de Voorde",
        "Maxim Akhmetzhanov",
        "Maxim Gerasimov",
        "Maximiliano Cristiani",
        "Mehmet Sinan Özdemir",
        "Michael Nadtochi",
        "Michael Rühl",
        "Michael Sacher",
        "Michael Watson",
        "Michał Zachariasiewicz",
        "Miguel Angel Zotto",
        "Murat Erdemsel",
        "Müge Üner",
        "Neri Piliu",
        "Nick Jones",
        "Nicolas di Rago",
        "Nicolás di Rago",
        "Nikita Gerdt",
        "Nikita Vasilev",
        "Nikos Dimitropoulos",
        "Nito",
        "Nito Garcia",
        "Octavio Fernandez",
        "Onur Gumrukcu",
        "Onur Gümrükçü",
        "Onurhan Ateşli",
        "Orlando Reyes",
        "Özgür Arin",
        "Pablo Alvarez",
        "Pablo Fernández Gómez",
        "Pablo Inza",
        "Pablo Rodriguez",
        "Panagiotis Triantafyllou",
        "Piotr Bochiński",
        "Piotr Roemer",
        "Piotr Woźniak",
        "Rafael Busch",
        "Raphael Passaquay",
        "Rauli Choque",
        "Raúli Choque",
        "Rebecca Rorick Smith",
        "René–Marie Meignan",
        "Ricardo Biggeri",
        "Roberto Leiva",
        "Roberto Zuccarino",
        "Rodrigo Fonti",
        "Rodrigo Rufino",
        "Rodrigo Videla",
        "Ruben Veliz",
        "Santiago Hernandez",
        "Sebastian Achaval",
        "Sebastian Albano",
        "Sebastian Arce",
        "Sebastian Archaval",
        "Sebastian Jimenez",
        "Sebastian Nieva",
        "Sercan Yigit",
        "Serhat Onuk",
        "Silviu Gusat",
        "Stavros Chersoniotakis",
        "Stefan Knauß",
        "Steinar Refsdal",
        "Sven Breynaert",
        "Thoma",
        "Utku Kuley",
        "Vaggelis Hatzopoulos",
        "Vanesa Villalba",
        "Vanessa Gauch",
        "Vasco Martins",
        "Vincenzo Bisogno",
        "Vito Raffanelli",
        "Walter “Chino” Laborde",
        "Yalçın Badem",
        "Yannick Vanhove",
        "Yury Shtykin",
        "Özgür Arin"
      ].each do |leader_name|
        Leader.create(name: leader_name)
    end
  end
end
