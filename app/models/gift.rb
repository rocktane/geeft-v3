class Gift < ApplicationRecord
  belongs_to :user
  belongs_to :event, optional: true

  validates :budget, :age, :genre, :occasion, :relationship, presence: true
  validates :budget, numericality: { greater_than: 0 }
  validates :relationship, presence: true

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
    list_of_interests = interests.compact_blank.join(',')

    response = client.chat(
      parameters: {
        model: ENV['MODEL'],
        messages: [{
          role: 'user',
          content: <<~PROMPT
            Je veux une liste de trente cadeaux pour #{relationship} qui est de sexe #{genre} et qui a  #{age} ans, ces centres d'intêrets sont : #{list_of_interests}.
            Le cadeau sera offert à l'occasion de #{occasion} et mon budget est de #{budget} euros. J'ai besoin de ton aide pour trouver des idées de cadeaux en suivant scrupuleusement les consignes suivantes :

            - La réponse doit consister uniquement en une liste numérotée de 30 cadeaux, chaque cadeau doit être sur une nouvelle ligne, numéroté de 1 à 30, Aucun autre texte ne doit être inclus
            - Ne propose JAMAIS de mugs, de porte-clés, de cartes cadeaux, d'abonnements, de supports de livres, de lampes de lecture, de jeux de société de type escape room, de CD, de DVD, de gants de jardinage, d'horloge murale
            - Ne JAMAIS ajouter de produits avec des motifs spécifiques (floral, animal, etc.)
            - Ne JAMAIS ajouter de tournures de phrases comme 'pour...' ça ne sert à rien d'expliquer à quoi ça servirait
            - Soit concis et utilise un minimum de mots pour décrire les propositions
            - Si tu proposes des marque-pages, assure-toi qu'ils soient en matériaux spécifiques et de qualité (par exemple en bois, en argent ou en or)
            - Ne propose JAMAIS de vaisselle ou de produits similaires (ex. ensemble de verres) sauf pour les crémaillères
            - Évite les descriptions comportant des adjectifs comme tendance, 'élégant', 'pratique', 'stylé' ou 'confortable', 'de qualité'
            - Les propositions doivent être précises et bien adaptées aux intérêts mentionnés. Par exemple, si l'intérêt est la photographie, proposez des équipements ou accessoires photographiques pertinents (ex : trépied de voyage, sac à dos avec compartiment pour appareil photo)

            Je compte sur toi, merci d'avance pour ton aide !
          PROMPT
        }]
      }
    )
    response['choices'].first['message']['content']
  end

  def update_gifts(client, comment, interests)
    list_of_interests = interests.compact_blank.join(', ')

    response = client.chat(
      parameters: {
        model: ENV['MODEL'],
        messages: [{
          role: 'user',
          content: <<~PROMPT
            Je veux une liste de trente cadeaux pour #{relationship} qui est de sexe #{genre} et qui a  #{age}, voila son message : #{comment}
            Si cela peut t'aider, ces centres d'intêrets sont : #{list_of_interests} qui doivent représenter maximum 50% des cadeaux, le commentaiire est le plus important.
            Le cadeau sera offert à l'occasion de #{occasion} et mon budget est de #{budget} euros, J'ai besoin de ton aide pour trouver des idées de cadeaux en suivant scrupuleusement les consignes suivantes :

            - Prendre en compte ce commentaire : #{comment} et ajuster les propositions en conséquence
            - La réponse doit consister uniquement en une liste numérotée de 30 cadeaux. Chaque cadeau doit être sur une nouvelle ligne, numéroté de 1 à 30. Aucun autre texte ne doit être inclus
            - Ne propose JAMAIS de mugs, de porte-clés, de cartes cadeaux, d'abonnements, de supports de livres, de lampes de lecture, de jeux de société de type escape room, de CD, de DVD, de gants de jardinage, d'horloge murale
            - Ne JAMAIS ajouter de produits avec des motifs spécifiques (floral, animal, etc.)
            - Ne JAMAIS ajouter de tournures de phrases comme 'pour...' ça ne sert à rien d'expliquer à quoi ça servirait
            - Soit concis et utilise un minimum de mots pour décrire les propositions
            - Si tu proposes des marque-pages, assure-toi qu'ils soient en matériaux spécifiques et de qualité (par exemple en bois, en argent ou en or)
            - Ne propose JAMAIS de vaisselle ou de produits similaires (ex. ensemble de verres) sauf pour les crémaillères
            - Évite les descriptions comportant des adjectifs comme tendance, 'élégant', 'pratique', 'stylé' ou 'confortable', 'de qualité'
            - Les propositions doivent être précises et bien adaptées aux intérêts mentionnés. Par exemple, si l'intérêt est la photographie, proposez des équipements ou accessoires photographiques pertinents (ex : trépied de voyage, sac à dos avec compartiment pour appareil photo)

            Je compte sur toi, merci d'avance pour ton aide !
          PROMPT
        }]
      }
    )
    response['choices'].first['message']['content']
  end
end
