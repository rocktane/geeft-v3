class Gift < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true

  validates :budget, :age, :genre, :occasion, :relationship, :interests, presence: true
  validates :budget, numericality: { greater_than: 0 }

  OCCASIONS = %w[Noël Anniversaire Saint-Valentin Fêtes\ des\ parents Fête\ des\ grands-mères Pot\ de\ départ
              Crémaillère Baptème Mariage Bar-Mitzvah Bat-Mitzvah Baby\ shower
              EVJF EVG Remise\ de\ diplôme Juste\ comme\ ça]
  INTERESTS = %w[Musique Sport Nature Art Voyage Lecture Cuisine Technologie Mode Bien-être Cosmétique Humour Cinéma
              Jardinage Jeux-vidéo Langues\ étrangères Astronomie Bricolage Danse Théatre Spectacle Histoire
              Psychologie Développement\ personnel Sptiritualité Astrologie Design]
  RELATIONSHIPS = %w[Parent Petit·e-ami·e Frère Soeur Enfant Collègue Grand-parent Cousin·e Oncle Tante Beau-parent
          Beau-frère Belle-soeur Neveu Nièce Petit-enfant BFF Ami·e Conjoint·e Connaissance Patron·ne
          Parrain Marraine Filleul·e Professeur·e Moi-même]

  def gen_gifts(client, budget, age, genre, occasion, interests, relationship)

    list_of_interests = interests.compact_blank.join(", ")

    response = client.chat(
      parameters: {
        model: ENV["MODEL"],
        messages: [{
          role: "user",
          content: "Je veux une liste de trente cadeaux pour #{relationship}. Cette personne est de sexe #{genre}, elle est âgée de #{age} ans et aime #{list_of_interests}. Le cadeau sera offert à l'occasion de #{occasion}. Mon budget est de #{budget} euros. Je veux que le résultat soit intégré dans une liste sans ta propre réponse. Sois concis, je veux juste les cadeaux sans explications."
        }]
      })
    response["choices"].first["message"]["content"]
  end

  def update_gifts(client, comment, interests)

    list_of_interests = interests.compact_blank.join(", ")

    response = client.chat(
      parameters: {
        model: ENV["MODEL"],
        messages: [{
          role: "user",
          content: "À partir de la liste générée(#{generated_list}), je t'avais demandé une liste de trente cadeaux pour #{relationship} qui est âgée de #{age} ans et est de sexe #{genre}. Ce cadeau sera offert à l'occasion de #{occasion}, je t'avais précisé que cette personne aime #{list_of_interests}. Je veux que tu prennes en compte ce commentaire: #{comment} et que tu me donnes une nouvelle liste numérotée de trente cadeaux. Ta réponse ne doit inclure rien d'autre que cette nouvelle liste numérotée."
        }]
      })
    response["choices"].first["message"]["content"]
  end
end
