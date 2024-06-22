# Cormack-Jolly-Seber (CJS) Survival Analysis with Bayesian Modelling Documentation

## 1. Goals and Objective
The primary objective of the Cormack-Jolly-Seber survival analysis using a Bayesian approach is to gain insights into the survival probability, detection probability, and cumulative survival probability of salmon throughout their life cycle. This includes their outmigration to larger watersheds and oceans, as well as their return to their native habitats. This model follows the theoretical approaches outlined in the [‘Bottlenecks to Survival’ – Survival modelling update](https://github.com/brahmwg/Bottlenecks_MDS_Capstone/blob/main/documentation/Bottlenecks%20survival%20modelling_Full%20summary_May%202023_LKE%20(2).docx), authored by Dr. Laura Elmar at the Pacific Salmon Foundation.

## 2. Methods
Our study implemented the Cormack-Jolly-Seber (CJS) model (Cormack, 1964; Jolly, 1965; Seber, 1965), which was originally designed for studying bird migration. However, due to the model's heavy reliance on recapture rates, we incorporated Bayesian modeling to address concerns arising from the lack of recapture events. By utilizing prior knowledge through Bayesian modeling, we aim to enhance the analytical power of our sparse recapture data. This approach allows us to obtain more precise and accurate parameter estimates, thereby improving the reliability of our findings.

Our data is modeled using hierarchical modeling to estimate survival and detection probabilities across multiple stages of the fish's outmigration-return path. The model combines elements of the CJS model with Bayesian techniques to handle sparse recapture data effectively. This method was chosen and was originally implemented by Dr. Laura Elmar at the Pacific Salmon Foundation.

### 2.1 Prior Distribution
| Parameter | Description | 
| --- | --- | 
| $\phi_j$ | Describes the survival probability of salmon at stage $j$. |
| $p_j$ | Describes the detection probability of salmon at stage $j$. |

Both parameters are modeled using the beta distribution with fixed shape parameters of $\alpha=1$ and $\beta=1$. Hence, this corresponds to a uniform distribution over the interval [0, 1]. This means that before observing any data, every possible value of $\phi_j$ and $p_j$ is between 0 and 1 in an equally likely manner.
$$\phi_j \sim \text{Beta}(1,1)$$
$$p_j \sim \text{Beta}(1,1)$$

### 2.2 Likelihood
| Latent Variable | Description | 
| --- | --- | 
| $\phi_j$ | Describes the survival probability of salmon at stage $j$. |
| $p_j$ | Describes the detection probability of salmon at stage $j$. |

Our likelihood distributions are as follows, where $i$ indicates individual salmon. returns a binary value of either  or  to depict survival status of the fish, and 
 depicts the binary value of either  or  to depict tagging status of the fish
$$\phi_j \sim \text{Beta}(1,1)$$
$$p_j \sim \text{Beta}(1,1)$$

$$z_{i,j} \sim \text{Bernoulli}(\phi_j, z_{i,j-1})$$
$$y_{i,j} \sim \text{Bernoulli}(p_j, z_{i,j-1})$$

$$\text{Survship}_j = \prod_{k=1}^{i=1} \phi_k$$

## 2. Results