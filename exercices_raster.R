library(terra)
library(sf)
# 1. Reprojetez les données raster d'altitude dans le système de coordonnées Lambert 93 et  découpez la pour la faire correpondre aux limites communales de Catus

# Importer le raster
elev_raw <- rast("data/elevation.tif") 

# Importer les communes
commune <- vect("data/lot.gpkg", layer = "communes")

# Reprojection
model_proj <- project(x = elev_raw, y = "EPSG:2154")
elev <- project(x = elev_raw, y = model_proj, method = "bilinear")

# Sélection Catus
catus <- subset(commune, commune$INSEE_COM == "46064") 

# Crop
crop_catus <- crop(elev, catus)

# Affichage (optionnel)
plot(crop_catus)
plot(catus, add = TRUE)

# Mask
mask_catus <- mask(crop_catus, catus)
plot(mask_catus)


# 2. Quelles sont les altitudes minimales et maximales au sein de la commune de Catus ?
mask_catus


# 3. Faites de même avec les données d'occupation du sol. N'oubliez pas de convertir les intitulés réels des types d’occupation du sol.

# Importer le raster
clc_raw <- rast("data/clc.tif") 

# Reprojeter
model_proj <- project(x = clc_raw, y = "EPSG:2154")
clc <- project(x = clc_raw, y = model_proj, method = "near")

# Attribuer les intitulés et couleurs des classes (reprendre code du cours)
intitule_poste <- c(
  "Tissu urbain continu", "Tissu urbain discontinu",
  "Zones industrielles ou commerciales et installations publiques",
  "Réseaux routier et ferroviaire et espaces associés", 
  "Aéroports","Extraction de matériaux", 
  "Equipements sportifs et de loisirs", 
  "Terres arables hors périmètres d'irrigation", "Vignobles", 
  "Vergers et petits fruits", 
  "Prairies et autres surfaces toujours en herbe à usage agricole", 
  "Systèmes culturaux et parcellaires complexes", 
  "Surfaces essentiellement agricoles (interrompues par espaces nat.)", 
  "Forêts de feuillus", "Forêts de conifères", "Forêts mélangées",
  "Pelouses et pâturages naturels", 
  "Landes et broussailles", "Végétation sclérophylle", 
  "Forêt et végétation arbustive en mutation", 
  "Cours et voies d'eau", "Plans d'eau"
)
couleur_off <- c("#E6004D", "#FF0000", "#CC4DF2", "#CC0000", "#E6CCE6", "#A600CC", 
                 "#FFE6FF", "#FFFFA8", "#E68000", "#F2A64D", "#E6E64D", "#FFE64D", 
                 "#E6CC4D", "#80FF00", "#00A600", "#4DFF00", "#CCF24D", "#A6FF80", 
                 "#A6E64D", "#A6F200", "#00CCF2", "#80F2E6")

plot(catus)
plot(clc, levels = intitule_poste,
     col = couleur_off,  type = "classes", add = TRUE)
plot(catus, add = TRUE)


# Crop
crop_catus <- crop(clc, catus)

plot(crop_catus, levels = intitule_poste,
     col = couleur_off,  type = "classes", add = TRUE)
plot(catus, add = TRUE)

# Mask
mask_catus <- mask(crop_catus, catus)

plot(mask_catus, levels = intitule_poste,
     col = couleur_off,  type = "classes")

mask_catus

# Afficher seulement les entités présentes (légende)

# 4. Combien de modalités différentes ? Reclassifiez les
clc_by_class <- segregate(mask_catus, keep = TRUE, other = NA)

plot(clc_by_class)

plot(mask_catus,
     type = "classes",
     levels = c("Tissu urbain discontinu",
                "Extraction de matériaux",
                "Prairies et autres surfaces toujours en herbe à usage agricole",
                "Systèmes culturaux et parcellaires complexes",
                "Surfaces essentiellement agricoles, interrompues par des espaces naturels importants",
                "Forêts de feuillus",
                "Forêts de conifères",
                "Forêt et végétation arbustive en mutation"),
     col = c("#FF0000", "#A600CC", "#E6E64D", "#FFE64D", "#E6CC4D", "#80FF00", "#00A600",
             "#A6F200"), 
     plg = list(cex = 0.7))


# Reclassification

# Niveau 2
reclassif <- matrix(c(110, 119, 1,
                      130, 139, 2,
                      230, 239, 3,
                      240, 249, 4,
                      310, 319, 5,
                      320, 329, 6),
                    ncol = 3, 
                    byrow = TRUE)

clc_6 <- classify(mask_catus, rcl = reclassif)

plot(clc_6,
     type = "classes",
     levels = c("Zones urbanisées", "Mines, décharges et chantiers", "Prairies",
                "Zones agricoles hétérogènes", "Forêts",
                "Milieux à végétation arbustive et/ou herbacée"),
     col = c("#E6004D", "#A600CC", "#E6E64D", "#FFE6A6", "#80FF00", "#CCF24D"), 
     plg = list(cex = 0.7))



# Niveau 1
reclassif <- matrix(c(100, 199, 1,
                      200, 299, 2,
                      300, 399, 3),
                    ncol = 3, 
                    byrow = TRUE)

clc_3 <- classify(mask_catus, rcl = reclassif)

plot(clc_3,
     type = "classes",
     levels = c("Territoires artificialisés",
                "Territoires agricoles",
                "Forêts et milieux semi-naturels"),
     col = c("#E6004D", "#FFFFA8", "#80FF00"), 
     plg = list(cex = 0.7))


# Convertir en vecteur
clc_3_sf <- as.polygons(clc_3)
clc_3_sf <- st_as_sf(clc_3_sf)

plot(clc_3_sf)

