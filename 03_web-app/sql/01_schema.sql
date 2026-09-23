

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";

-- Base de données :  `enael028`

-- Structure de la table `COMMUNE`

CREATE TABLE `COMMUNE` (
  `code_insee` varchar(5) NOT NULL,
  `nom_ville` varchar(100) NOT NULL,
  `departement` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Structure de la table `FOURNISSEUR`

CREATE TABLE `FOURNISSEUR` (
  `id_fournisseur` int(11) NOT NULL,
  `nom_fournisseur` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Structure de la table `POINT_DE_CHARGE`

CREATE TABLE `POINT_DE_CHARGE` (
  `id_point_charge` varchar(6) NOT NULL,
  `puissance_nominale` int(11) NOT NULL,
  `prise_type_combo_ccs` tinyint(1) NOT NULL,
  `prise_type_2` tinyint(1) NOT NULL,
  `prise_type_ef` tinyint(1) NOT NULL,
  `prise_type_chademo` tinyint(1) NOT NULL,
  `ID_station` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Structure de la table `STATION`

CREATE TABLE `STATION` (
  `ID` int(11) NOT NULL,
  `nom` varchar(100) NOT NULL,
  `implantation_station` varchar(100) NOT NULL,
  `condition_acces` varchar(100) NOT NULL,
  `accessibilite_pmr` varchar(100) NOT NULL,
  `paiement_acte` varchar(100) NOT NULL,
  `latitude` float NOT NULL,
  `longitude` float NOT NULL,
  `code_insee` varchar(5) NOT NULL,
  `id_fournisseur` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Index pour la table `COMMUNE`

ALTER TABLE `COMMUNE`
  ADD PRIMARY KEY (`code_insee`);


-- Index pour la table `FOURNISSEUR`

ALTER TABLE `FOURNISSEUR`
  ADD PRIMARY KEY (`id_fournisseur`);


-- Index pour la table `POINT_DE_CHARGE`

ALTER TABLE `POINT_DE_CHARGE`
  ADD PRIMARY KEY (`id_point_charge`),
  ADD KEY `PDC_ID_station_IDX` (`ID_station`);


-- Index pour la table `STATION`

ALTER TABLE `STATION`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `STATION_code_insee_IDX` (`code_insee`),
  ADD KEY `STATION_id_fournisseur_IDX` (`id_fournisseur`);


-- AUTO_INCREMENT pour les tables exportées
-- pour la table `FOURNISSEUR`
ALTER TABLE `FOURNISSEUR`
  MODIFY `id_fournisseur` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

-- pour la table `STATION`

ALTER TABLE `STATION`
  MODIFY `ID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

-- Contraintes pour la table `POINT_DE_CHARGE`

ALTER TABLE `POINT_DE_CHARGE`
  ADD CONSTRAINT `POINT_DE_CHARGE_ibfk_1` FOREIGN KEY (`ID_station`) REFERENCES `STATION` (`ID`);


-- Contraintes pour la table `STATION`

ALTER TABLE `STATION`
  ADD CONSTRAINT `STATION_ibfk_1` FOREIGN KEY (`code_insee`) REFERENCES `COMMUNE` (`code_insee`),
  ADD CONSTRAINT `STATION_ibfk_2` FOREIGN KEY (`id_fournisseur`) REFERENCES `FOURNISSEUR` (`id_fournisseur`);

